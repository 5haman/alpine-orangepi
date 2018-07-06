#!/bin/bash

set -e

CORES="4"
MEMORY="1G"
INITRAMFS="./.out/initramfs-linux.img"
KERNEL="./boot/Image"
#BOOT_PARAMS="initrd=initramfs-linux.img quiet panic=1 console=ttyAMA0"
BOOT_PARAMS="initrd=initramfs-linux.img panic=1 console=ttyAMA0"
SSH_HOST_PORT="5022"

qemu-system-aarch64 -cpu cortex-a53 \
      -M virt -nographic -no-reboot \
      -m "${MEMORY}" -smp "${CORES}" \
      -kernel "${KERNEL}" \
      -append "${BOOT_PARAMS}" \
      -initrd "${INITRAMFS}" \
      -device "virtio-net-pci,netdev=net0" \
      -netdev "user,id=net0,hostfwd=tcp::${SSH_HOST_PORT}-:22"
