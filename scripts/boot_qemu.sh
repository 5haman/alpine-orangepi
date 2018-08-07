#!/bin/bash

set -e

cpu="4"
mem="512M"
params="console=ttyAMA0 panic=1 zram.num_devices=2 net.ifnames=0"
kernel=".out/boot/Image"
initramfs=".out/initramfs-linux.img"

qemu-system-aarch64 -M virt -cpu cortex-a53 \
	-m "${mem}" -smp "${cpu}" \
	-no-reboot -serial stdio \
	-kernel "${kernel}" \
	-append "${params}" \
	-initrd "${initramfs}"
	#-usb \
	#-device usb-ehci \
        #-device usb-host,vendorid=0x0bda,productid=0x8179
