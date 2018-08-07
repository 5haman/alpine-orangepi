FROM homemate/alpine-s6:3.8

RUN apk-install bash \
    && apk-install -t .build-deps build-base git \
	automake autoconf libxml2-dev fuse-dev curl-dev \
    && apk-install e2fsprogs fuse libxml2 \
    && git clone --singe-branch --depth 1 https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs \
    && cd /tmp/s3fs \
    && ./autogen.sh \
    && ./configure --prefix=/usr 
    && make \
    && make install \
    && cont-cleanup
    && apk-remove .build-deps

RUN mkdir -p /lib64 /etc/rexray /run/docker/plugins /var/lib/rexray/volumes \
    && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ADD rexray /usr/bin/rexray
ADD rexray.yml /etc/rexray/rexray.yml

ENTRYPOINT ["/init"]
