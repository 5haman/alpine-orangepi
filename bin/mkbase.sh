#!/bin/bash

set -e

alpine_ver="v3.8"
arch="aarch64"
repo_url="http://dl-cdn.alpinelinux.org/alpine"

initramfs_pkgs='alpine-baselayout busybox-\d execline musl-\d\. s6-\d s6-linux-utils s6-portable-utils skalibs libcom_err e2fsprogs-libs libblkid-\d libuuid-\d e2fsprogs-\d e2fsprogs-extra'
rootfs_pkgs='alpine-baselayout alpine-keys dropbear-\d apk-tools-\d busybox-\d dnsmasq-\d execline haveged-\d musl-\d\. s6-\d s6-linux- s6-portable- s6-rc- scanelf skalibs zlib-\d s6-networking s6-dns bearssl-\d'

startdir="$(pwd)"
outdir="${startdir}/.out"

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
cp -r "${startdir}/fs/initramfs/"* "${outdir}/initramfs/"
cp -r "${startdir}/fs/rootfs/"* "${outdir}/rootfs/"

# copy required kernel modules
cp -r "${outdir}/boot/lib/modules/"* "${outdir}/initramfs/lib/modules/"

cd "${outdir}/rootfs"
mkdir -p '../initramfs/mnt'
tar -czf '../initramfs/mnt/rootfs.tgz' .

cd "${outdir}/initramfs"
find . |  cpio --create --format='newc' | gzip -1 > "${outdir}/initramfs-linux.img"
