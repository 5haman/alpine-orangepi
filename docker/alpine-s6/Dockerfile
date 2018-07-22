FROM arm64v8/alpine:3.8

ADD rootfs/ /

RUN apk update \
 && apk upgrade \
 && apk-install ca-certificates curl \
 && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-aarch64.tar.gz \
  | tar -xzf - -C / \
 && cont-cleanup

ENTRYPOINT ["/init"]
