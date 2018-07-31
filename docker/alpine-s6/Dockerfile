FROM scratch

ARG arch
ARG ver
ADD alpine-minirootfs-${ver}.0-${arch}.tar.gz /

ADD rootfs/ /

RUN apk update \
    && apk upgrade \
    && apk-install ca-certificates curl \
    && curl -SL "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-${arch}.tar.gz" \
	| tar xz \
    && cont-cleanup

ENTRYPOINT ["/init"]
