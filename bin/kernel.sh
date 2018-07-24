#!/usr/bin/env bash

set -e

builddir=${BUILD_DIR:-"/data/build"}
output=${OUTPUT_DIR:-"/data/output"}
toolchain=${CROSS_COMPILE:-"aarch64-linux-musl-"}
#toolchain=${CROSS_COMPILE:-"arm-linux-musleabihf-"}

atf_url="https://github.com/apritzel/arm-trusted-firmware.git"
kernel_url="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
uboot_url="git://git.denx.de/u-boot.git"

platform="sun50iw1p1"
#platform="sun8i"
atf_ver="allwinner"
kernel_ver="v4.18-rc5"
uboot_ver="master"

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

# build arm firmware
make ARCH=aarch64 CROSS_COMPILE=$toolchain PLAT=$platform -C $builddir/arm-trusted-firmware bl31
cp $builddir/arm-trusted-firmware/build/$platform/release/bl31.bin $builddir/u-boot/

# build u-boot
make ARCH=arm CROSS_COMPILE="$toolchain" -C $builddir/u-boot orangepi_zero_plus_defconfig
make ARCH=arm CROSS_COMPILE="$toolchain" -j2 -C $builddir/u-boot
cat $builddir/u-boot/spl/sunxi-spl.bin $builddir/u-boot/u-boot.itb > $output/boot/uboot.bin
cp $builddir/u-boot/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dtb $builddir/linux/arch/arm64/boot/dts/allwinner/

# build kernel
cp /data/kernel.config $builddir/linux/.config
make ARCH=arm64 CROSS_COMPILE="$toolchain" -C $builddir/linux menuconfig
cat $builddir/linux/.config > /data/kernel.config

make ARCH=arm64 CROSS_COMPILE="$toolchain" -j2 -C $builddir/linux dtbs Image
rm -rf $output/boot/Image $output/boot/lib/modules
make ARCH=arm64 CROSS_COMPILE="$toolchain" INSTALL_MOD_PATH=$output/boot -C $builddir/linux modules modules_install
cp -f $builddir/linux/arch/arm64/boot/Image $output/boot
cp -f $builddir/linux/.config $output/boot/kernel.config
cp -f $builddir/linux/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-zero-plus.dtb $output/boot/orangepi-zero-plus.dtb

echo -e "\n=> Finished succesfully!\n"
