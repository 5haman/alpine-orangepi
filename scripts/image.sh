#!/bin/bash

set -e

overlay="/data/overlay"
output="/data/output"

size_p1=12
size_p2=$(($(du -hs ${output}/rootfs | awk '{ print $1 }' | tr -d 'A-Z')/2+2))
size_p3=1

start_p1=2048
start_p2=$((${start_p1}+${size_p1}*2048))
start_p3=$((${start_p2}+${size_p2}*2048))

boot="${output}/boot/uboot.bin"
sdcard="${output}/sdcard.img"
dtbs="sun50i-h5-orangepi-zero-plus.dtb"

mnt="$(mktemp -d)"
rm -f $sdcard

# Installing bootloader
dd if=/dev/zero bs=1M count=1 of="$sdcard" 2> /dev/null 1>&2
dd if="$boot" conv=notrunc bs=8k seek=1 of="$sdcard" 2> /dev/null 1>&2
dd if=/dev/zero count=$size_p1 conv=notrunc oflag=append bs=1M seek=$((start_p1*512)) of="$sdcard" 2> /dev/null 1>&2

# Formating boot partition
losetup -f -o $(($start_p1*512)) ${sdcard}
dev="$(losetup -a | tail -n 1 | awk '{ print $1 }' | tr -d ':')"
mkfs.vfat -n BOOT $dev 2> /dev/null 1>&2

# Copying boot files
mount $dev $mnt
mkdir -p "$mnt/config" "$mnt/boot"
cp -f "${output}/boot/Image" "$mnt/boot/vmlinux"
cp -f "${output}/initramfs-linux.img" "$mnt/boot/ramdisk.img"
cp -f "${output}/boot/dtbs/${dtbs}" "$mnt/boot/orangepi-zero-plus.dtb"
mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Orange Pi Zero Plus" -d "${overlay}/boot/boot.cmd" "${mnt}/boot.scr" 2> /dev/null 1>&2
cp -rfa "${overlay}/config" "$mnt/"
umount $mnt
rm -rf $mnt
losetup -d $dev

# Formating root partition
dd if=/dev/zero count=$size_p2 conv=notrunc oflag=append bs=1M of="$sdcard" 2> /dev/null 1>&2
losetup -f -o $(($start_p2*512)) ${sdcard}

# Copying root files
cd "${output}/rootfs"
mksquashfs . "${dev}" -noappend -b 4K -comp lz4 #-Xhc
losetup -d $dev

# Formating data partition
dd if=/dev/zero count=$size_p3 conv=notrunc oflag=append bs=1M of="$sdcard" 2> /dev/null 1>&2
losetup -f -o $((${start_p3} * 512)) ${sdcard}
mkfs.ext4 -O ^has_journal -E stride=2,stripe-width=1024 -b 4096 -L Data $dev 2> /dev/null 1>&2
losetup -d $dev

# Creating partition table
echo -ne "o\nn\np\n1\n${start_p1}\n$(($start_p2-1))\nt\nb\nn\np\n2\n${start_p2}\n$((${start_p3}-1))\nn\np\n3\n${start_p3}\n\nw\n" | fdisk -u "${sdcard}" 2> /dev/null 1>&2 || true

echo "Finished succesfully!"
