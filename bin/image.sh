#!/bin/bash

size=128
size_p2=7
start=2048
start_p2=$(($start+$size*2048))

overlay="/data/overlay"
output="/data/output"
boot="${overlay}/boot/boot.img"
sdcard="${output}/sdcard.img"

mnt="$(mktemp -d)"
rm -f $sdcard

echo "=> Installing u-boot..."
dd if="$boot" conv=notrunc bs=1M seek=0 of="$sdcard" 2> /dev/null 1>&2
dd if=/dev/zero count=$((size+size_p2)) conv=notrunc oflag=append bs=1M seek=$((start*512)) of="$sdcard" 2> /dev/null 1>&2

echo "=> Formating fat partition..."
losetup -f -o $(($start * 512)) ${sdcard}
drive="$(losetup -a | tail -n 1 | awk '{ print $1 }' | tr -d ':')"
mkfs.vfat -n BOOT $drive 2> /dev/null 1>&2

echo "=> Formating ext4 partition..."
losetup -f -o $((${start_p2} * 512)) ${sdcard}
drive_p2="$(losetup -a | tail -n 1 | awk '{ print $1 }' | tr -d ':')"
mkfs.ext4 -O ^has_journal -E stride=2,stripe-width=1024 -b 4096 -L Docker $drive_p2 2> /dev/null 1>&2

mkdir -p "$mnt"
mount $drive $mnt
mkdir -p "$mnt/config"

echo "=> Copying boot files..."
cp -rfa "${output}/boot/Image" $mnt/
cp -rfa "${overlay}/config" $mnt/
cp -rfa "${output}/initramfs-linux.img" $mnt/
cp -rfa "${overlay}/boot/boot.scr" $mnt/
cp -rfa "${overlay}/boot/boot.cmd" $mnt/
cp -rfa "${overlay}/boot/dtbs/" $mnt/
umount $mnt

mount $drive_p2 $mnt
touch "$mnt/.needresize"
#tar zxf "${overlay}/docker.tgz" -C $mnt 2> /dev/null
umount $mnt
rm -rf $mnt

losetup -a | awk '{ print $1 }' \
| while read dev; do
    losetup -d $dev
done

echo "=> Creating partition table..."
sync
echo -ne "o\nn\np\n1\n${start}\n$((start_p2-1))\nt\nb\nn\np\n2\n${start_p2}\n\nw\n" | fdisk -u "${sdcard}" 2> /dev/null 1>&2

echo "=> Finished succesfully!"
