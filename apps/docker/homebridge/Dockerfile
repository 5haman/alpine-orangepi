ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

ENV NODE_ENV=production

RUN apk-install nodejs avahi-compat-libdns_sd \
    && apk-install -t .build-deps build-base nodejs-npm python avahi-dev \
    && npm install -g --unsafe-perm \
	homebridge \
	homebridge-knx \
	homebridge-mqtt \
	homebridge-config-ui-x \
	homebridge-automation-calendar \
    && apk-remove .build-deps \
    && find /usr/lib/node_modules -type f | grep -vE '\.js$|\.map$|\.ttf$|\.woff$|\.woff2$|config|/bin/|package\.json|\.node$|\.json|\.conf$|\.xml$|\.gyp$|\.gypi$|\.css$|\.html$|\.png$|\.jpg$|\.gif$|\.ico$|\.svg$' | xargs rm -f \
    && rm -rf /usr/lib/node_modules/npm \
    && cont-cleanup

ADD rootfs /
ADD config/config.json /root/.homebridge/config.json
ADD config/knx_config.json /root/.homebridge/knx_config.json

ENTRYPOINT ["/init"]
