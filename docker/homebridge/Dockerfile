ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

RUN apk-install nodejs avahi-compat-libdns_sd \
    && apk-install -t .build-deps build-base nodejs-npm python avahi-dev \
    && npm install -g --unsafe-perm \
	homebridge \
	homebridge-knx \
	homebridge-config-ui-x \
	homebridge-weather-station-extended \
    && cont-cleanup

ADD rootfs/ /

ENTRYPOINT ["/init"]
