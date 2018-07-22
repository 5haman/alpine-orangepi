#!/bin/bash

set -e

host='x86_64'
arch='aarch64'
#arch='armhf'
alpine_ver='v3.8'
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

initfs_pkgs="busybox e2fsprogs e2fsprogs-extra execline"
rootfs_pkgs="alpine-baselayout alpine-keys apk-tools bash busybox curl dnsmasq docker dropbear fuse haveged htop e2fsprogs libgcc libstdc++ libxml2 s6-linux-init s6-rc s6-portable-utils tmux wireless-tools wpa_supplicant"

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

apk_install "${initfs_pkgs}" "${output}/initramfs" 2> /dev/null || true
apk_install "${rootfs_pkgs}" "${output}/rootfs" 2> /dev/null || true

# copy overlay files
cp -rf ${overlay}/initramfs/* ${output}/initramfs
cp -rf ${output}/boot/lib/modules ${output}/initramfs/lib/
cp -rf ${output}/boot/lib/modules ${output}/rootfs/lib/
cp -rf ${overlay}/boot/firmware ${output}/initramfs/lib/
cp -rf ${overlay}/boot/firmware ${output}/rootfs/lib/
cp -rf ${overlay}/rootfs/* ${output}/rootfs

# post install
cp -f "${output}/rootfs/bin/busybox" "${output}/rootfs/usr/bin/c_rehash" "${output}/rootfs/usr/sbin/update-ca-certificates" "${output}/rootfs/lib/libcrypto.so.43.0.1" "${output}/rootfs/tmp/"
cp -f /bin/busybox "${output}/rootfs/bin/busybox"
cp -f /bin/busybox /tmp/
cp -f /usr/sbin/update-ca-certificates "${output}/rootfs/usr/sbin/update-ca-certificates"
cp -f /usr/bin/c_rehash "${output}/rootfs/usr/bin/c_rehash"
cp -f /lib/ld-musl-${host}.so.1 "${output}/rootfs/lib/"
cp -f /lib/libcrypto.so.43.0.1 "${output}/rootfs/lib/"

chroot "${output}/rootfs" /bin/busybox --install -s
chroot "${output}/rootfs" chown root:shadow /etc/shadow
chroot "${output}/rootfs" chmod 640 /etc/shadow
chroot "${output}/rootfs" add-shell '/bin/bash'
chroot "${output}/rootfs" addgroup -S dnsmasq
chroot "${output}/rootfs" adduser -S -D -H -h /dev/null -s /sbin/nologin -G dnsmasq -g dnsmasq dnsmasq
chroot "${output}/rootfs" addgroup -S docker
chroot "${output}/rootfs" ln -sf /run/docker /etc/docker
chroot "${output}/rootfs" addgroup -S catchlog
chroot "${output}/rootfs" adduser -S -D -H -s /bin/false -G catchlog -g catchlog catchlog
chroot "${output}/rootfs" update-ca-certificates --fresh
mv -f "${output}/rootfs/tmp/busybox" "${output}/rootfs/bin/"
mv -f "${output}/rootfs/tmp/c_rehash" "${output}/rootfs/usr/bin/"
mv -f "${output}/rootfs/tmp/update-ca-certificates"  "${output}/rootfs/usr/sbin/"
mv -f "${output}/rootfs/tmp/libcrypto.so.43.0.1"  "${output}/rootfs/lib/"

echo "${baseurl}/main" > ${output}/rootfs/etc/apk/repositories
echo "${baseurl}/community" >> ${output}/rootfs/etc/apk/repositories

cat <<EOF > ${output}/rootfs/etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=$(echo ${alpine_ver} | tr -d 'v').0
PRETTY_NAME="Alpine Linux ${alpine_ver}"
HOME_URL="http://alpinelinux.org"
BUG_REPORT_URL="http://bugs.alpinelinux.org"
EOF

mkdir -p ${output}/rootfs/var/lib/docker ${output}/rootfs/var/log
rm -f ${output}/initramfs/var/cache/apk/* ${output}/rootfs/var/cache/apk/*

#cd ${output}/rootfs/var
#tar -czf ../mnt/var.tgz .

cd ${output}/rootfs
mksquashfs . ${output}/initramfs/mnt/rootfs.img -b 4K -comp lz4 -Xhc #-Xcompression-level 1

mv /tmp/busybox /bin/busybox
cd ${output}/initramfs
find . | cpio --create --format=newc | lz4 --favor-decSpeed -9 -l -BD > ../initramfs-linux.img
