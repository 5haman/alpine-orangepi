#!/bin/sh

set -ex

builddir=/tmp
pkgname=fuse
pkgver=2.9.7
source="https://github.com/libfuse/libfuse/releases/download/fuse-$pkgver/fuse-$pkgver.tar.gz"

cd "$builddir"
curl -sSL "$source" | tar -xz

cd fuse-*
./configure \
	--prefix=/usr \
       	--enable-static \
        --enable-shared \
        --disable-example \
        --enable-lib \
        --enable-util \
        --bindir=/bin

make
make install
