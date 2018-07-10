#!/bin/bash

set -e

arch="aarch64"
alpine_ver="v3.7"
baseurl="http://dl-cdn.alpinelinux.org/alpine/${alpine_ver}"

pkgs='alpine-baselayout
apk-tools
busybox
dbus-libs
dnsmasq
dropbear
execline
haveged
libnl3
libressl2.6-libcrypto
libressl2.6-libssl
musl
pcsc-lite-libs
s6
s6-linux-utils
s6-portable-utils
s6-rc
skalibs
wireless-tools
wpa_supplicant
zlib'

startdir="/data"
dest="/data/output/rootfs"

source "${startdir}/bin/functions.sh"

rm -rf "${dest}"
mkdir -p "${dest}"

# install rootfs packages
pkg_list "${pkgs}" \
| while read pkg; do
  apk_install $pkg
done

find "${dest}" -maxdepth 1 -type f | xargs rm -f

# copy overlay files
cp -r "${startdir}/fs/rootfs/"* "${dest}"
