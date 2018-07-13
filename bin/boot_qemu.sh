#!/bin/bash

set -e

cpu="4"
mem="512M"
params="console=ttyAMA0 panic=1"
kernel="./kernel/Image"
initramfs=".out/initramfs-linux.img"
#sdcard="/root/sdcard.img"
#sdcard="/mnt/flash/orangepi/armbian_5.51.img"
sdcard="/mnt/flash/orangepi/archlinuxarm-orange_pi_zero_plus-20180111.img"

qemu-system-aarch64 -cpu cortex-a53 \
	-M virt -no-reboot -nographic \
	-m "${mem}" -smp "${cpu}" \
	-kernel "${kernel}" \
	-append "${params}" \
	-initrd "${initramfs}"
