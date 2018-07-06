#!/bin/bash

set -ex

builddir=${BUILD_DIR:-"/data/build"}
output=${OUTPUT_DIR:-"/data/output"}

#atf_url="https://github.com/ARM-software/arm-trusted-firmware"
#kernel_url="https://github.com/megous/linux"
#uboot_url="https://github.com/megous/u-boot"

atf_url="https://github.com/apritzel/arm-trusted-firmware.git"
kernel_url="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
uboot_url="git://git.denx.de/u-boot.git"

#platform="sun50i_a64"
#kernel_ver="orange-pi-4.18"
#uboot_ver="orange-pi"

platform="sun50iw1p1"
atf_ver="allwinner"
kernel_ver="v4.18-rc3"
uboot_ver="master"

mkdir -p $builddir $output
rm -rf $output/*
cd $builddir

# download sources
if [ ! -d arm-trusted-firmware ]; then
  git clone -b $atf_ver --depth 1 --single-branch $atf_url arm-trusted-firmware
fi

if [ ! -d u-boot ]; then
  git clone -b $uboot_ver --depth 1 --single-branch $uboot_url u-boot
fi

if [ ! -d linux ]; then
  git clone -b $kernel_ver --depth 1 --single-branch $kernel_url linux
fi

# build arm firmware
cd $builddir/arm-trusted-firmware
make ARCH=arm64 PLAT=$platform -j2 bl31
cp ./build/$platform/release/bl31.bin $builddir/u-boot/

# build u-boot
cd $builddir/u-boot
make ARCH=arm orangepi_zero_plus2_defconfig
make ARCH=arm -j2
cat ./spl/sunxi-spl.bin ./u-boot.itb > $output/u-boot.bin

# build kernel
cd $builddir/linux
cp /usr/local/share/kernel_config .config
yes '' | make ARCH=arm64 oldconfig
make ARCH=arm64 -j2 Image modules dtbs
make ARCH=arm64 INSTALL_MOD_PATH=$output modules_install

cp -f ./arch/arm64/boot/Image $output
cp -f ./.config $output/config
cp -f ./arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-zero-plus2.dtb $output

echo -e "\n=> Finished succesfully!\n"
