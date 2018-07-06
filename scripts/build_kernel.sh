#!/bin/bash

set -x

output="$HOME/kernel"
cross_comp="arm-linux-gnueabi"
repo_base="https://github.com/orangepi-xunlong/OrangePiH5"
parts="kernel uboot scripts external toolchain"

mkdir -p "$output"
cd "$output"

for part in $(echo $parts | tr ' ' '\n'); do
  git clone --depth 1  --single-branch "${repo_base}_${part}.git" $part
done
