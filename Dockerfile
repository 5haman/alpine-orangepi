FROM alpine:3.7

#ENV DEBIAN_FRONTEND="noninteractive" \
ENV CROSS_COMPILE="aarch64-linux-musl-" \
    TERM=xterm-color

RUN apk -U --no-cache update \
 && apk -U --no-cache upgrade \
 && apk -U --no-cache add bash bc curl sed tar wget xz \
 && curl -SL http://skarnet.org/toolchains/cross/aarch64-linux-musl-8.1.0.tar.xz | \
    tar xfJ - --strip-components=1 -C /

#	bc curl dosfstools git initramfs-tools \
#	device-tree-compiler libssl-dev make parted rsync tar \
#	sudo swig u-boot-tools unzip vim wget bison flex \
#	python-dev ncurses-dev gcc curl tar xzdec xz-utils \
# && curl -sSL 'https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz' | tar -xJ -C /tmp \

ENTRYPOINT ["/bin/bash"]
