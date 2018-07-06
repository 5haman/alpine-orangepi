#!/bin/bash

set -ex

plat=sun50i_a64
output="$HOME/build"
cc=aarch64-linux-gnu-
repo_base="https://github.com/orangepi-xunlong/OrangePiH5"
parts="kernel uboot scripts external"

mkdir -p $output/output
cd $output

# get sources
for part in $(echo $parts | tr ' ' '\n'); do
  if [ ! -d $part ]; then
    git clone --depth 1  --single-branch "${repo_base}_${part}.git" $part
  fi
done

# get and activate toolchain
if [ ! -d toolchain ]; then
  curl -sSL 'https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz' | tar -xJ
  mv gcc-linaro-* toolchain
fi
export PATH="$PATH:$PWD/toolchain/bin"

# get bootloaders code
git clone --depth 1 --single-branch https://github.com/ARM-software/arm-trusted-firmware.git firmware
git clone --depth 1 --single-branch git://git.denx.de/u-boot.git

# build arm firmware
cd firmware
make ARCH=aarch64 CROSS_COMPILE=$cc -j4 PLAT=$plat DEBUG=0 bl31
cp build/$plat/release/bl31.bin ../u-boot/

# build u-boot
cd ../u-boot
make ARCH=arm CROSS_COMPILE=$cc -j4 orangepi_zero_plus2_defconfig
make ARCH=arm CROSS_COMPILE=$cc -j4
cat spl/sunxi-spl.bin u-boot.itb > $output/output/u-boot-sunxi-with-spl.bin
