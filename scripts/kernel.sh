#!/usr/bin/env bash

set -e

builddir=${BUILD_DIR:-"/data/build"}
output=${OUTPUT_DIR:-"/data/output"}
toolchain=${CROSS_COMPILE:-"aarch64-linux-musl-"}

atf_url="https://github.com/apritzel/arm-trusted-firmware.git"
kernel_url="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
uboot_url="git://git.denx.de/u-boot.git"
rtl8189_url="https://github.com/jwrdegoede/rtl8189ES_linux"

platform="sun50iw1p1"
#platform="sun8i"
atf_ver="allwinner"
kernel_ver="v4.18-rc6"
uboot_ver="master"

ncpu=$(cat /proc/cpuinfo | grep processor | wc -l)

#rm -rf $output/boot
mkdir -p $builddir $output/boot

# download sources
if [ ! -d $builddir/arm-trusted-firmware ]; then
  git clone -b $atf_ver --depth 1 --single-branch $atf_url $builddir/arm-trusted-firmware
fi

if [ ! -d $builddir/u-boot ]; then
  git clone -b $uboot_ver --depth 1 --single-branch $uboot_url $builddir/u-boot
fi

if [ ! -d $builddir/linux ]; then
  git clone -b $kernel_ver --depth 1 --single-branch $kernel_url $builddir/linux
fi

if [ ! -d $builddir/rtl8189fs ]; then
  git clone -b rtl8189fs --depth 1 --single-branch $rtl8189_url $builddir/rtl8189fs
  cd ${builddir}/rtl8189fs/include
  patch -su < /data/patches/rtl8189_disable_debug_spam.patch
fi

# build arm firmware
make ARCH=arm64 CROSS_COMPILE=$toolchain -j${ncpu} PLAT=$platform DEBUG=0 -C $builddir/arm-trusted-firmware bl31
cp $builddir/arm-trusted-firmware/build/$platform/release/bl31.bin $builddir/u-boot/

# build u-boot
if [ ! -f $builddir/u-boot/.config ]; then
  make ARCH=arm CROSS_COMPILE="$toolchain" -C $builddir/u-boot -j${ncpu} orangepi_zero_plus_defconfig
fi
make ARCH=arm CROSS_COMPILE="$toolchain" -C $builddir/u-boot -j${ncpu} menuconfig
make ARCH=arm CROSS_COMPILE="$toolchain" -j${ncpu} -C $builddir/u-boot
cat $builddir/u-boot/spl/sunxi-spl.bin $builddir/u-boot/u-boot.itb > $output/boot/uboot.bin
cp $builddir/u-boot/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dtb $builddir/linux/arch/arm64/boot/dts/allwinner/

# build kernel
cp /data/kernel.config $builddir/linux/.config
make ARCH=arm64 CROSS_COMPILE="$toolchain" -C $builddir/linux menuconfig
cat $builddir/linux/.config > /data/kernel.config

make ARCH=arm64 CROSS_COMPILE="$toolchain" -j${ncpu} -C $builddir/linux Image
rm -rf $output/boot/Image $output/boot/lib/modules
make ARCH=arm64 CROSS_COMPILE="$toolchain" INSTALL_MOD_PATH=$output/boot -j${ncpu} -C $builddir/linux modules modules_install
cp -f $builddir/linux/arch/arm64/boot/Image $output/boot
cp -f $builddir/linux/.config $output/boot/kernel.config
mkdir -p $output/boot/dtbs
cp -f $builddir/linux/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-zero-plus.dtb $output/boot/dtbs/

# build rtl8189fs kernel module
make ARCH=arm64 CROSS_COMPILE=${toolchain} -j${ncpu} KSRC=$builddir/linux M=${builddir}/rtl8189fs -C ${builddir}/rtl8189fs modules

kern=$(ls ${output}/boot/lib/modules)
mkdir -p ${output}/boot/lib/modules/${kern}/kernel/drivers/staging/
cp ${builddir}/rtl8189fs/8189fs.ko ${output}/boot/lib/modules/${kern}/kernel/drivers/staging/
gzip ${output}/boot/lib/modules/${kern}/kernel/drivers/staging/8189fs.ko
depmod -a -b ${output}/boot ${kern}

echo -e "\n=> Finished succesfully!\n"
