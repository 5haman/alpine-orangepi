FROM homemate/alpine-s6:3.8

RUN apk-install nodejs avahi-compat-libdns_sd \
 && apk-install -t .build-deps build-base nodejs-npm python avahi-dev \
 && npm install -g --unsafe-perm \
    homebridge \
    homebridge-knx \
    homebridge-config-ui-x \
    homebridge-broadband \
    homebridge-dacp \
    homebridge-homeassistant \
    homebridge-weather-station-extended \
 && cont-cleanup

ADD rootfs/ /

ENTRYPOINT ["/init"]
