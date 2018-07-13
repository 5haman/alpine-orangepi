#!/bin/bash

host='x86_64'
arch='aarch64'
alpine_ver='v3.7'
#apk_ver='2.9.1-r2'
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

initfs_pkgs='busybox e2fsprogs e2fsprogs-extra execline'
rootfs_pkgs='alpine-baselayout alpine-keys apk-tools busybox busybox-suid dnsmasq dropbear haveged e2fsprogs s6-rc s6-portable-utils' #wireless-tools wpa_supplicant'

overlay='/data/overlay'
output='/data/output'

apk_install() {
	#curl -s "${baseurl}/main/${host}/apk-tools-static-${apk_ver}.apk" | tar -xz -C / sbin/apk.static
	#/sbin/apk.static add --initdb --root ${2} --arch "${arch}"
	#/sbin/apk.static --repository "${baseurl}/main" \
	apk --repository "${baseurl}/main" \
		--repository "${baseurl}/community" \
		--update-cache --allow-untrusted \
		--root ${2} --arch $arch --initdb add ${1}
	#rm -f "${2}/var/cache/apk/"*
	#rm /sbin/apk.static
}

rm -rf ${output}/rootfs ${output}/initramfs
mkdir -p ${output}/rootfs ${output}/initramfs

apk_install "${rootfs_pkgs}" "${output}/rootfs" 2> /dev/null
apk_install "${initfs_pkgs}" "${output}/initramfs" 2> /dev/null

# copy overlay files
cp -rf ${overlay}/rootfs/* ${output}/rootfs
cp -r ${overlay}/initramfs/* ${output}/initramfs

echo "${baseurl}/main" > ${output}/rootfs/etc/apk/repositories
echo "${baseurl}/community" >> ${output}/rootfs/etc/apk/repositories

cd ${output}/rootfs
tar -cf ${output}/initramfs/mnt/rootfs.tar .
gzip -1 ${output}/initramfs/mnt/rootfs.tar

cd ${output}/initramfs
find . | cpio --create --format=newc 2>/dev/null | gzip -1 > ../initramfs-linux.img
