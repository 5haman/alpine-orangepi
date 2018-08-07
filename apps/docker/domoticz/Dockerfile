ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

ENV VERSION="4.9700"

RUN addgroup -S domoticz \
    && adduser -S -D -h /var/lib/domoticz -s /sbin/nologin -G domoticz -g domoticz domoticz

RUN apk-install libssl1.0 libgcc libstdc++ libcurl zlib sqlite-libs lua5.2-libs \
        libusb-compat mosquitto-libs++ openzwave-libs python3-dev \
    && apk-install -t .build-deps cmake libressl-dev zlib-dev curl-dev \
        boost-dev sqlite-dev lua5.2-dev mosquitto-dev libusb-compat-dev \
        openzwave-dev build-base git \
    && git clone -b ${VERSION} --depth 1  https://github.com/domoticz/domoticz /tmp/domoticz \
    && cd /tmp/domoticz \
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
        CMakeLists.txt \
    && make \
    && make DESTDIR="/" install \
    && curl -SL -o /tmp/theme.zip "https://github.com/flatsiedatsie/domoticz-aurora-theme/archive/master.zip" \
    && unzip -o /tmp/theme.zip -d /tmp \
    && cp -Rf /tmp/domoticz-aurora-theme-master/* /opt/domoticz/www/styles \
    && apk-remove .build-deps \
    && cont-cleanup

ADD rootfs /

ENTRYPOINT ["/init"]
