#!/bin/bash

set -e

arch="aarch64"
alpine_ver="3.7"
baseurl="http://dl-cdn.alpinelinux.org/alpine/v${alpine_ver}"

pkgs='busybox
execline
musl
skalibs'

startdir="/data"
dest="/data/output/initramfs"

source "${startdir}/bin/functions.sh"

rm -rf "${dest}"
mkdir -p "${dest}"

# Install skeleton
#curl -sSL "${baseurl}/releases/${arch}/alpine-minirootfs-${alpine_ver}.0-${arch}.tar.gz" | tar -xzf - -C "${outdir}/initramfs"

# install initramfs packages
pkg_list "${pkgs}" \
| while read pkg; do
  apk_install $pkg initramfs
done
find "${dest}" -maxdepth 1 -type f | xargs rm -f

# copy overlay files
cp -r "${startdir}/fs/initramfs/"* "${dest}"

# copy required kernel modules
#cp -r "${startdir}/output/boot/lib/modules/"* "${dest}/lib/modules/"

cd "${startdir}/output/rootfs"
mkdir -p "${dest}/mnt"
tar -czf "${dest}/mnt/rootfs.tgz" .

cd "${dest}"
find . | cpio --create --format='newc' 2>/dev/null | gzip -6 > "../initramfs-linux.img"
