#!/bin/bash

set -e

arch="aarch64"
#arch="x86_64"
alpine_ver="3.7"
baseurl="http://dl-cdn.alpinelinux.org/alpine/v${alpine_ver}"

pkgs='busybox
execline
musl
skalibs'

startdir="/data"
outdir="/data/output"

source "${startdir}/bin/functions.sh"

rm -rf "${outdir}/initramfs"
mkdir -p "${outdir}/initramfs"

# Install skeleton
curl -sSL "${baseurl}/releases/${arch}/alpine-minirootfs-${alpine_ver}.0-${arch}.tar.gz" | tar -xzf - -C "${outdir}/initramfs"

# install initramfs packages
pkg_list "${pkgs}" \
| while read pkg; do
  apk_install $pkg initramfs
done
find "${outdir}/initramfs" -maxdepth 1 -type f | xargs rm -f

# copy overlay files
cp -r "${startdir}/fs/initramfs/"* "${outdir}/initramfs/"

# copy required kernel modules
#cp -r "${outdir}/boot_${arch}/lib/modules/"* "${outdir}/initramfs/lib/modules/"
cp -r "${outdir}/boot/lib/modules/"* "${outdir}/initramfs/lib/modules/"

cd "${outdir}/rootfs"
mkdir -p "${outdir}/initramfs/mnt"
tar -czf "${outdir}/initramfs/mnt/rootfs.tgz" .

cd "${outdir}/initramfs"
find . | cpio --create --format='newc' 2>/dev/null | gzip -1 > "${outdir}/initramfs-linux.img"
