FROM scratch

ARG arch
ARG ver
ADD alpine-minirootfs-${ver}.0-${arch}.tar.gz /

ADD rootfs/ /

RUN set -x \
    && apk update \
    && apk upgrade \
    && apk-install ca-certificates curl \
    && if [ ${arch} == "x86_64" ]; then \
	curl -SL "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz"; else \
	curl -SL "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-${arch}.tar.gz"; fi \
	| tar xz \
    && cont-cleanup

ENTRYPOINT ["/init"]
