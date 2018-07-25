#!/bin/bash

set -e

cpu="4"
mem="512M"
params="console=ttyAMA0 panic=1 rootfstype=squashfs rootwait ro net.ifnames=0"
#kernel="./overlay/boot/Image"
kernel=".out/boot/Image"
initramfs=".out/initramfs-linux.img"
#sdcard="/root/sdcard.img"
#sdcard="/mnt/flash/orangepi/armbian_5.51.img"
#sdcard="/mnt/flash/orangepi/archlinuxarm-orange_pi_zero_plus-20180111.img"

qemu-system-aarch64 -M virt -cpu cortex-a53 \
	-no-reboot -serial stdio \
	-m "${mem}" -smp "${cpu}" \
	-kernel "${kernel}" \
	-append "${params}" \
	-initrd "${initramfs}" \
	-usb \
	-device usb-ehci \
        -device usb-host,vendorid=0x0bda,productid=0x8179
