#!/bin/bash

set -e

host="x86_64"
arch="aarch64"
alpine_ver="v3.6"
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

version="0.2.5"
initfs_pkg="busybox e2fsprogs e2fsprogs-extra execline"
base_pkg="alpine-baselayout alpine-keys apk-tools busybox curl"
rootfs_pkg="bash dnsmasq docker dropbear e2fsprogs e2fsprogs-extra fuse haveged htop libcrypto1.0 libgcc libstdc++ libxml2 jq openssh-keygen openssh-client python s6-linux-init s6-rc s6-portable-utils wireless-tools wpa_supplicant"

overlay='/data/overlay'
output='/data/output'

apk_install() {
    apk --repository "${baseurl}/main" \
	--repository "${baseurl}/community" \
	--update-cache --allow-untrusted \
	--root ${2} --arch $arch --initdb add ${1}
}

rm -rf ${output}/initramfs ${output}/rootfs
mkdir -p ${output}/initramfs/lib ${output}/rootfs/lib

apk_install "${base_pkg}" "${output}/rootfs" 2> /dev/null || true
cp -f "${output}/rootfs/bin/busybox" "${output}/rootfs/tmp/"
cp -f /bin/busybox "${output}/rootfs/bin/busybox"
cp -f /lib/ld-musl-${host}.so.1 "${output}/rootfs/lib/"

apk_install "${initfs_pkg}" "${output}/initramfs" 2> /dev/null || true
apk_install "${rootfs_pkg}" "${output}/rootfs" 2> /dev/null || true

# copy overlay files
cp -rf ${overlay}/initramfs/* ${output}/initramfs
cp -rf ${overlay}/rootfs/* ${output}/rootfs

# copy kernel modules
cp -rf ${output}/boot/lib/modules ${output}/initramfs/lib/
cp -rf ${output}/boot/lib/modules ${output}/rootfs/lib/

# copy deploy files
cp -rf /etc/ansible ${output}/rootfs/etc/

# copy firmware data
cp -rf ${overlay}/boot/firmware ${output}/initramfs/lib/
cp -rf ${overlay}/boot/firmware ${output}/rootfs/lib/

chroot "${output}/rootfs" /bin/busybox --install -s

update-ca-certificates
rm -rf "${output}/rootfs/etc/ssl"
cp -r /etc/ssl "${output}/rootfs/etc"

mv -f "${output}/rootfs/tmp/busybox" "${output}/rootfs/bin/"
rm -f "${output}/rootfs/lib/ld-musl-${host}.so.1" 

echo "${baseurl}/main" > ${output}/rootfs/etc/apk/repositories
echo "${baseurl}/community" >> ${output}/rootfs/etc/apk/repositories

cat <<EOF > ${output}/rootfs/etc/os-release
NAME="HomeOS Linux"
ID=homeos
VERSION_ID=${version}
PRETTY_NAME="HomeOS Linux ${version}"
EOF

mkdir -p ${output}/rootfs/var/lib/docker ${output}/rootfs/var/log
rm -f ${output}/initramfs/var/cache/apk/* ${output}/rootfs/var/cache/apk/*

cd ${output}/rootfs
mkdir -p ${output}/initramfs/mnt
mksquashfs . ${output}/initramfs/mnt/rootfs.img -comp lz4 #-Xhc 
#mksquashfs . ${output}/initramfs/mnt/rootfs.img -b 16K -comp lz4 #-Xhc 

cd ${output}/initramfs
#find . | cpio --create --format=newc | lz4 -l -5 -BD > ../initramfs-linux.img
find . | cpio --create --format=newc | lz4 -l --favor-decSpeed -1 -BD > ../initramfs-linux.img
