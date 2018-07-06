#!/bin/bash

set -e

alpine_ver="v3.8"
#kernel_ver="4.15.0-rc2"
kernel_ver="4.18.0-rc1"
arch="aarch64"
repo_url="http://dl-cdn.alpinelinux.org/alpine"

initramfs_pkgs='alpine-baselayout busybox-\d execline musl-\d\. s6-\d s6-linux-utils s6-portable-utils skalibs libcom_err e2fsprogs-libs libblkid-\d libuuid-\d e2fsprogs-\d e2fsprogs-extra'
rootfs_pkgs='alpine-baselayout alpine-keys dropbear-\d apk-tools-\d busybox-\d dnsmasq-\d execline haveged-\d musl-\d\. s6-\d s6-linux- s6-portable- s6-rc- scanelf skalibs zlib-\d s6-networking s6-dns bearssl-\d'

startdir="$(pwd)"
outdir="${startdir}/output"

pkg_list() {
  curl -sSL "${repo_url}" | grep '\.apk' \
  | grep -E "$(echo "${1}" | sed 's# #|"#g' | sed 's#|"$##g')" \
  | awk -F 'href="' '{ print $2 }' | awk -F '">' '{ print $1 }' | grep -vE '\-doc|\-dev|acf\-'
}

apk_install() {
  curl -sSL "${repo_url}/${1}" | tar -xzf - -C "${outdir}/${2}"
}

# remove previous builds
rm -rf "${outdir}/*"
mkdir -p "${outdir}/initramfs" "${outdir}/rootfs"

# install initramfs packages
repo_url="${repo_url}/${alpine_ver}/main/${arch}"
pkg_list "${initramfs_pkgs}" \
| while read pkg; do
  apk_install $pkg 'initramfs'
done

# install rootfs packages
repo_url="${repo_url}/${alpine_ver}/main/${arch}"
pkg_list "${rootfs_pkgs}" \
| while read pkg; do
  apk_install $pkg 'rootfs'
done

find "${outdir}/initramfs" -type f -maxdepth 1 | xargs rm -f
find "${outdir}/rootfs" -type f -maxdepth 1 | xargs rm -f

# copy overlay files
cp -r "${startdir}/initramfs/"* "${outdir}/initramfs/"
cp -r "${startdir}/rootfs/"* "${outdir}/rootfs/"

# copy required kernel modules
cp -r "${startdir}/kernel/${kernel_ver}/lib/modules/"* "${outdir}/initramfs/lib/modules/"

#kernel_ver="$(ls "${startdir}/kernel/lib/modules")"
#mkdir -p "${outdir}/initramfs/lib/modules/${kernel_ver}"
#find "${startdir}/kernel/lib/modules" -type f | grep '\.dep$' | while read file; do cp $file "${outdir}/initramfs/lib/modules/${kernel_ver}/"; done
#find "${startdir}/kernel/lib/modules" -type d | grep -E 'wireless$|zram$|rfkill$|extra$' \
#| while read dir; do 
#  path="$(echo $dir | awk -F "${kernel_ver}" '{print $2 }' | tr -d '+')"
#  mkdir -p "${outdir}/initramfs/lib/modules/${kernel_ver}/${path}"
#  cp -r "$dir/"* "${outdir}/initramfs/lib/modules/${kernel_ver}/${path}/"
#done

cd "${outdir}/rootfs"
mkdir -p '../initramfs/mnt'
tar -czf '../initramfs/mnt/rootfs.tgz' .

cd "${outdir}/initramfs"
find . |  cpio --create --format='newc' | gzip -1 > "${outdir}/initramfs-linux.img"
