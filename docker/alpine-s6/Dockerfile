ARG ver
FROM alpine:${ver}

ADD rootfs/ /
ADD s6.tgz /

#ADD "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-${build}.tar.gz" /tmp/s6.tar.gz

RUN set -x \
    && apk update \
    && apk upgrade \
    && apk-install ca-certificates curl \
    && cont-cleanup

ENTRYPOINT ["/bin/sh"]
