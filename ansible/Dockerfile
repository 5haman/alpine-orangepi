FROM homemate/alpine-s6:3.6

RUN apk-install ansible py-pip \
    && pip install boto \
    && cont-cleanup

#ADD rootfs/ /

WORKDIR /etc/ansible

ENTRYPOINT ["/bin/sh"]
