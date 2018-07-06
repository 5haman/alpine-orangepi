FROM ubuntu:16.04

ENV DEBIAN_FRONTEND="noninteractive"

WORKDIR /usr/local

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl tar xzdec xz-utils \
 && curl -sSL 'https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz' | tar -xJ \
 && mv gcc-linaro-* toolchain \
 && apt-get remove -y xzdec xz-utils \
 && rm -rf /var/lib/apt/lists/* /tmp/* /root/*
 
RUN apt-get update \
 && apt-get install -y bc curl dosfstools git initramfs-tools \
	device-tree-compiler libssl-dev make parted rsync tar \
	sudo swig u-boot-tools unzip vim wget bison flex \
	python-dev ncurses-dev gcc \
 && rm -rf /var/lib/apt/lists/* /tmp/* /root/*

ENV CROSS_COMPILE="aarch64-linux-gnu-"
ENV PATH="/usr/local/toolchain/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ADD build.sh /usr/local/bin/
ADD kernel_config /usr/local/share/
WORKDIR /data

VOLUME /data

ENTRYPOINT ["/bin/bash"]
