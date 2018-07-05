#!/bin/bash

set -e

startdir="$(pwd)"
initramfs_pkgs='alpine-baselayout busybox-\d execline musl-\d\. s6-\d s6-linux-utils s6-portable-utils skalibs libcom_err e2fsprogs-libs libblkid-\d libuuid-\d e2fsprogs-\d e2fsprogs-extra'

rootfs_pkgs='alpine-baselayout alpine-keys dropbear-\d apk-tools-\d busybox-\d dnsmasq-\d execline haveged-\d musl-\d\. s6-\d s6-linux- s6-portable- s6-rc- scanelf skalibs zlib-\d s6-networking s6-dns bearssl-\d'

base_url="http://dl-cdn.alpinelinux.org/alpine"
alpine_ver="v3.8"
arch="aarch64"
outdir="./output"

rm -rf "${outdir}"
mkdir -p "${outdir}/initramfs" "${outdir}/rootfs"

pkg_list() {
  curl -sSL "${repo_url}" | grep '\.apk' \
  | grep -E "$(echo "${1}" | sed 's# #|"#g' | sed 's#|"$##g')" \
  | awk -F 'href="' '{ print $2 }' | awk -F '">' '{ print $1 }' | grep -vE '\-doc|\-dev|acf\-'
}

apk_install() {
  curl -sSL "${repo_url}/${1}" | tar -xzf - -C "${outdir}/${2}"
}

repo_url="${base_url}/${alpine_ver}/main/${arch}"
pkg_list "${initramfs_pkgs}" \
| while read pkg; do
  apk_install $pkg 'initramfs'
done

repo_url="${base_url}/${alpine_ver}/main/${arch}"
pkg_list "${rootfs_pkgs}" \
| while read pkg; do
  apk_install $pkg 'rootfs'
done

find "${outdir}/initramfs" -type f -maxdepth 1 | xargs rm -f
find "${outdir}/rootfs" -type f -maxdepth 1 | xargs rm -f

cp -r "${startdir}/overlay/initramfs/"* "${outdir}/initramfs/"
cp -r "${startdir}/overlay/rootfs/"* "${outdir}/rootfs/"

# copy required kernel modules
kernel_ver="$(ls "${startdir}/overlay/kernel/lib/modules")"
mkdir -p "${outdir}/initramfs/lib/modules/${kernel_ver}"
ls -la "${outdir}/initramfs/lib/modules/${kernel_ver}"
find "${startdir}/overlay/kernel/lib/modules" -type f | grep '\.dep$' | while read file; do cp $file "${outdir}/initramfs/lib/modules/${kernel_ver}/"; done
find "${startdir}/overlay/kernel/lib/modules" -type d | grep -E 'wireless$|zram$|rfkill$|extra$' \
| while read dir; do 
  path="$(echo $dir | awk -F "${kernel_ver}" '{print $2 }' | tr -d '+')"
  mkdir -p "${outdir}/initramfs/lib/modules/${kernel_ver}/${path}"
  cp -rv "$dir/"* "${outdir}/initramfs/lib/modules/${kernel_ver}/${path}/"
done

cd "${outdir}/rootfs"
mkdir -p '../initramfs/mnt'
tar -czf '../initramfs/mnt/rootfs.tgz' .

cd "${startdir}"
cd "${outdir}/initramfs"
find . |  cpio --create --format='newc' | gzip -9 > "../initramfs-linux.img"
