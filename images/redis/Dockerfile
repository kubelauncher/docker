# syntax=docker/dockerfile:1
FROM alpine:3.23 AS builder

ARG REDIS_VERSION=8.4.0

RUN apk add --no-cache \
        build-base \
        linux-headers \
        openssl-dev \
        curl \
    && curl -fsSL "https://github.com/redis/redis/archive/refs/tags/${REDIS_VERSION}.tar.gz" \
        | tar xz -C /tmp \
    && cd "/tmp/redis-${REDIS_VERSION}" \
    && make -j"$(nproc)" BUILD_TLS=yes \
    && make install PREFIX=/opt/redis \
    && strip /opt/redis/bin/*

FROM alpine:3.23

ARG REDIS_VERSION=8.4.0

LABEL org.opencontainers.image.title="redis" \
      org.opencontainers.image.description="Redis in-memory data store" \
      org.opencontainers.image.version="${REDIS_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

RUN apk add --no-cache \
        libssl3 \
        libcrypto3 \
        libgcc \
        libstdc++ \
        su-exec \
        tzdata \
    && addgroup -S -g 1001 redis \
    && adduser -S -u 1001 -G redis -h /data redis \
    && mkdir -p /data /opt/redis/etc \
    && chown -R redis:redis /data /opt/redis

COPY --from=builder /opt/redis/bin/ /opt/redis/bin/
COPY rootfs/entrypoint.sh /opt/redis/entrypoint.sh

RUN chmod +x /opt/redis/entrypoint.sh \
    && ln -s /opt/redis/bin/* /usr/local/bin/

ENV REDIS_PORT="6379" \
    REDIS_PASSWORD="" \
    REDIS_EXTRA_FLAGS="" \
    REDIS_DISABLE_COMMANDS="" \
    PATH="/opt/redis/bin:${PATH}"

VOLUME ["/data"]
WORKDIR /data
EXPOSE 6379

USER 1001
ENTRYPOINT ["/opt/redis/entrypoint.sh"]
CMD ["redis-server"]
