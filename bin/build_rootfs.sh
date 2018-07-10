#!/bin/bash

set -e

arch="aarch64"
#arch="x86_64"
alpine_ver="v3.7"
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

pkgs='alpine-baselayout
apk-tools
busybox
dnsmasq
dropbear
execline
musl
s6
s6-linux-utils
s6-portable-utils
s6-rc
skalibs
zlib'

startdir="/data"
#startdir="/root/alpine"

outdir="/data/output"
#outdir="/root/alpine/.out"

source "${startdir}/bin/functions.sh"

rm -rf "${outdir}/rootfs"
mkdir -p "${outdir}/rootfs"

# Install skeleton
#curl -sSL "${baseurl}/releases/${arch}/alpine-minirootfs-3.7.0-${arch}.tar.gz" | tar -xzf - -C "${outdir}/rootfs"

# install rootfs packages
pkg_list "${pkgs}" \
| while read pkg; do
  apk_install $pkg rootfs
done

find "${outdir}/rootfs" -maxdepth 1 -type f | xargs rm -f

# copy overlay files
cp -r "${startdir}/fs/rootfs/"* "${outdir}/rootfs/"
