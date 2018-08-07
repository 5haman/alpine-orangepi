FROM alpine:edge

ENV CROSS_COMPILE="aarch64-linux-musl-" \
    TOOLCHAIN="http://skarnet.org/toolchains/cross/aarch64-linux-musl-8.1.0.tar.xz" \
    PATH="/usr/local/toolchain/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add bash bc curl sed tar wget xz squashfs-tools make build-base \
	git coreutils bison flex dtc python-dev ncurses-dev openssl-dev \
	swig sudo dosfstools perl lz4 uboot-tools e2fsprogs e2fsprogs-extra\
    && mkdir -p /usr/local/toolchain \
    && curl -SL "${TOOLCHAIN}" | tar xfJ - --strip-components=1 -C /usr/local/toolchain

RUN apk add file patch

ENTRYPOINT ["/bin/bash"]
