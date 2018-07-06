#!/bin/bash

set -ex

sdcard="sdcard.img"
size=256

boot0_blob="./OrangePi-BuildLinux/orange/boot0_OPI.fex"
uboot_blob="./OrangePi-BuildLinux/orange/u-boot_OPI.fex"
boot0=8
uboot=16400
start=20480
end=$(( $size * 1024 * 1024 / 512 + $start - 1))
mnt="$(mktemp -d)"

rm -f $sdcard

echo "=> Instaling u-boot..."
dd if=/dev/zero bs=1M count=$((start/1024)) of="$sdcard" 2>/dev/null 1>&2
dd if="$boot0_blob" conv=notrunc bs=1k seek=$boot0 of="$sdcard" 2>/dev/null 1>&2
dd if="$uboot_blob" conv=notrunc bs=1k seek=$uboot of="$sdcard" 2>/dev/null 1>&2
dd if=/dev/zero count=${size} conv=notrunc oflag=append bs=1M seek=$((start/1024)) of="$sdcard" 2>/dev/null 1>&2

echo "=> Formating boot partition..."
drive="$(losetup --show --find -o $(($start * 512)) ${sdcard})"
mkfs.vfat -n BOOT $drive #2>/dev/null 1>&2

mkdir -p $mnt
mount $drive $mnt

echo "=> Copying boot files..."
cp -rfa Image $mnt
cp -rfa initramfs-linux.img $mnt
umount $mnt
rm -rf $mnt
losetup -d $drive
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
