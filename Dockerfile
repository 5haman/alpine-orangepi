FROM alpine:3.6

ENV CROSS_COMPILE="aarch64-linux-musl-" \
    TOOLCHAIN="http://skarnet.org/toolchains/cross/aarch64-linux-musl-8.1.0.tar.xz" \
    PATH="/usr/local/toolchain/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin" \
    TERM=xterm

RUN apk -U --no-cache update \
 && apk -U --no-cache upgrade \
 && apk -U --no-cache add bash bc curl sed tar wget xz squashfs-tools make build-base \
	git coreutils bison flex dtc python-dev ncurses-dev openssl-dev swig sudo dosfstools perl \
 && apk -U --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main add lz4 \
 && mkdir -p /usr/local/toolchain \
 && curl -SL "${TOOLCHAIN}" | tar xfJ - --strip-components=1 -C /usr/local/toolchain

ENTRYPOINT ["/bin/bash"]
