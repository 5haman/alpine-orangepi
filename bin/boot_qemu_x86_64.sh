#!/bin/bash

set -e

CORES="4"
MEMORY="1G"
INITRAMFS=".out/initramfs-linux.img"
KERNEL=".out/boot_x86_64/Image"
SDCARD="/dev/loop0"
BOOT_PARAMS="root=/dev/mmcblk0 console=ttyS0 panic=1"
SSH_HOST_PORT="5022"

qemu-system-x86_64 \
      -M pc -no-reboot \
      --serial stdio \
      -m "${MEMORY}" -smp "${CORES}" \
      -kernel "${KERNEL}" \
      -append "${BOOT_PARAMS}" \
      -initrd "${INITRAMFS}" \
      -netdev "type=user,id=net0,hostfwd=tcp::${SSH_HOST_PORT}-:22" \
      -device "virtio-net-pci,netdev=net0"
exit
 
qemu-system-aarch64 \
	-M virt -no-reboot \
	--serial stdio \
	-dtb .out/boot/orangepi-zero-plus.dtb \
	-device loader,addr=0xfd1a0104,data=0x8000000e,data-len=4 \
	-drive file=sdcard.img,if=sd,format=raw,index=1 
	#-device loader,file=/home/xilinx/Boot_test/MPSoC_Boot_Image/lab/workspace/MPSoc_Image/fsbl_a53_0_app.elf,cpu=0 \
	#-boot mode=5

exit
 
      #-device "virtio-net-pci,netdev=net0" \
      #-netdev "user,id=net0,hostfwd=tcp::${SSH_HOST_PORT}-:22"