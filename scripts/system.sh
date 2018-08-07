#!/bin/bash

set -e

host="x86_64"
arch="aarch64"
alpine_ver="v3.6"
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

version="0.3"
initfs_pkg="busybox e2fsprogs e2fsprogs-extra execline"
base_pkg="alpine-baselayout alpine-keys apk-tools busybox curl"
rootfs_pkg="bash dnsmasq docker dropbear fuse haveged htop s6-linux-init s6-rc s6-portable-utils wireless-tools wpa_supplicant"

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
cp -rf ${output}/boot/lib/modules ${output}/rootfs/lib/

# copy deploy files
cp -rf /etc/ansible ${output}/rootfs/etc/
#mkdir -p ${output}/rootfs/usr/src
#cp -rf /etc/docker ${output}/rootfs/usr/src/

chroot "${output}/rootfs" /bin/busybox --install -s

update-ca-certificates || true
rm -rf "${output}/rootfs/etc/ssl"
cp -r /etc/ssl "${output}/rootfs/etc"

mv -f "${output}/rootfs/tmp/busybox" "${output}/rootfs/bin/"
rm -f "${output}/rootfs/lib/ld-musl-${host}.so.1" 

echo "${baseurl}/main" > ${output}/rootfs/etc/apk/repositories
echo "${baseurl}/community" >> ${output}/rootfs/etc/apk/repositories

cat <<EOF > ${output}/rootfs/etc/os-release
NAME="Everhome Linux"
ID=everhome
VERSION_ID=${version}
PRETTY_NAME="Everhome Linux v${version}"
EOF

mkdir -p ${output}/rootfs/var/lib/docker ${output}/rootfs/var/log
rm -f ${output}/initramfs/var/cache/apk/* ${output}/rootfs/var/cache/apk/*
rm -rf ${output}/rootfs/etc/sysctl.d/00-alpine.conf \
	${output}/rootfs/etc/conf.d ${output}/rootfs/etc/init.d

# strip binaries
find ${output}/initramfs/ ${output}/rootfs/ -type f \
| while read file; do 
    file $file | grep aarch64 | grep 'not stripped' \
    | awk '{ print $1 }' | sed 's#:$##g'
done \
| while read binary; do 
    aarch64-linux-musl-strip -s "$binary"
done

rm -rf ${output}/initramfs/usr/include ${output}/initramfs/usr/src \
       ${output}/initramfs/usr/share
rm -rf ${output}/rootfs/usr/include ${output}/rootfs/usr/src

find ${output}/initramfs ${output}/rootfs -type f | grep -E '\.a$' | xargs rm -f

cd ${output}/initramfs
find . | cpio --create --format=newc | lz4 -l -1 -BD > ../initramfs-linux.img
