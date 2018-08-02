ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

VERSION="4.9700"

RUN addgroup -S domoticz \
    && adduser -S -D -h /var/lib/domoticz -s /sbin/nologin -G domoticz -g domoticz domoticz

RUN apk-install libssl libgcc libstdc++ libcurl zlib sqlite-libs lua5.2-libs \
	libusb-compat mosquitto-libs++ openzwave-libs python3 \
    && apk-install -t .build-deps cmake opensslssl-dev zlib-dev curl-dev \
	boost-dev sqlite-dev lua5.2-dev mosquitto-dev libusb-compat-dev \
	openzwave-dev python3-dev
    && curl -sSL "https://github.com/domoticz/domoticz/archive/${VERSION}.tar.gz" \
	| tar -xz - -C /tmp \
    && cd "/tmp/domoticz-${VERSION}" \
    && cmake \
	-DBUILD_SHARED_LIBS=True \
	-DUSE_STATIC_LIBSTDCXX=OFF \
	-DOpenZWave=/usr/lib/libopenzwave.so \
	-DUSE_STATIC_OPENZWAVE=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DUSE_BUILTIN_LUA=OFF \
	-DUSE_BUILTIN_MQTT=OFF \
	-DUSE_BUILTIN_SQLITE=OFF \
    && make \
    && make DESTDIR="/usr" install \
    && apk-remove .build-deps \
    && cont-cleanup

ADD rootfs /

ENTRYPOINT ["/init"]
