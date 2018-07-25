#!/bin/sh

set -ex

pkgver=0.7.5
source="http://red.libssh.org/attachments/download/218/libssh-$pkgver.tar.xz"

cd /tmp
curl -sSL "$source" | tar -xJ

cd libssh-*
mkdir build
cd build
cmake "$builddir" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make
