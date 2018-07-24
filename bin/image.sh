#!/bin/bash

set -e

size=100

overlay="/data/overlay"
output="/data/output"
boot="${overlay}/boot/boot.img"
sdcard="${output}/sdcard.img"

start=2048
mnt="$(mktemp -d -p $PWD)"

rm -f $sdcard

echo "=> Instaling u-boot..."
dd if="$boot" conv=notrunc bs=1M seek=0 of="$sdcard"
dd if=/dev/zero count=${size} conv=notrunc oflag=append bs=1M seek=$((start*512)) of="$sdcard" 2>/dev/null 1>&2

echo "=> Formating boot partition..."
drive="$(losetup --show --find -o $(($start * 512)) ${sdcard})"
mkfs.vfat -n BOOT $drive 2>/dev/null 1>&2

mkdir -p $mnt
mount $drive $mnt

echo "=> Copying boot files..."
cp -rfa "${output}/boot/Image" $mnt/
cp -rfa "${overlay}/config" $mnt/config
cp -rfa "${output}/initramfs-linux.img" $mnt/
cp -rfa "${overlay}/boot/boot.scr" $mnt/
cp -rfa "${overlay}/boot/boot.cmd" $mnt/
cp -rfa "${overlay}/boot/dtbs/" $mnt/
umount $mnt
rm -rf $mnt
losetup -D
sync

echo "=> Creating partition table..."
cat <<EOF | fdisk "${sdcard}" 2>/dev/null 1>&2
o
n
p
1
${start}

t
b
w
EOF
sync

echo "=> Finished succesfully!"
