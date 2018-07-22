FROM homemate/alpine-s6:3.8

RUN apk-install bash \
 && apk-install -t .build-deps build-base go git

ENTRYPOINT ["/bin/bash"]
