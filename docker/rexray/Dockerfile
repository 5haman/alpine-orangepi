FROM arm64v8/alpine:3.6

ADD s3fs.cpp /tmp/

RUN apk -U --no-cache add e2fsprogs e2fsprogs-extra fuse libxml2 libstdc++ libgcc openssl \
    && apk -U --no-cache add -t .build-deps automake autoconf build-base \
	git libxml2-dev fuse-dev curl-dev curl openssl-dev \
    && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz \
	| tar -xz \
    && git clone --depth 1 https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs \
    && cd /tmp/s3fs \
    && cp /tmp/s3fs.cpp src/ \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && apk -U --no-cache del .build-deps \
    && cd / && rm -rf /tmp/* /root/* /usr/include \
	/var/cache/apk/* \
    && mkdir -p /lib64 /etc/rexray /run/docker/plugins /var/lib/rexray/volumes \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ADD rexray /usr/bin/rexray
ADD rexray.yml /etc/rexray/rexray.yml

ENTRYPOINT ["/bin/sh"]
