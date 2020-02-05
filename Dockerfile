ARG BASE_IMAGE
FROM ${BASE_IMAGE:-library/python}:3.7-alpine

ARG QEMU_ARCH
ENV QEMU_ARCH=${QEMU_ARCH:-x86_64} S6_KEEP_ENV=1

COPY qemu/qemu-${QEMU_ARCH}-static /usr/bin/

RUN set -x && apk add --no-cache coreutils shadow dcron curl tzdata gcc logrotate musl-dev \
  && case "${QEMU_ARCH}" in \
    x86_64) S6_ARCH='amd64';; \
    aarch64) S6_ARCH='aarch64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://github.com/just-containers/s6-overlay/releases/download/v1.21.1.1/s6-overlay-${S6_ARCH}.tar.gz" \
  && curl -SLO "https://github.com/just-containers/socklog-overlay/releases/download/v3.1.0-2/socklog-overlay-${S6_ARCH}.tar.gz" \
  && tar -xzf s6-overlay-${S6_ARCH}.tar.gz -C / \
  && tar -xzf s6-overlay-${S6_ARCH}.tar.gz -C /usr ./bin \
  && tar -xzf socklog-overlay-${S6_ARCH}.tar.gz -C / \
  && rm -rf s6-overlay-${S6_ARCH}.tar.gz \
  && rm -rf socklog-overlay-${S6_ARCH}.tar.gz \
  && useradd -u 911 -U -d /config -s /bin/false abc \
  && usermod -G users abc \
  && mkdir -p /app /config /defaults \
  && apk del --purge \
  && rm -rf /tmp/*  \
  && sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf \
  && pip install lifx-photons-core python-crontab

COPY rootfs /

ENTRYPOINT ["/init"]
