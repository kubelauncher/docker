# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b AS builder

ARG REDIS_VERSION=8.4.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        pkg-config \
        curl \
        ca-certificates \
    && curl -fsSL "https://github.com/redis/redis/archive/refs/tags/${REDIS_VERSION}.tar.gz" \
        | tar xz -C /tmp \
    && cd "/tmp/redis-${REDIS_VERSION}" \
    && make -j"$(nproc)" BUILD_TLS=yes \
    && make install PREFIX=/opt/redis \
    && strip /opt/redis/bin/* \
    && rm -rf /var/lib/apt/lists/*

FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG REDIS_VERSION=8.4.0

LABEL org.opencontainers.image.title="redis" \
      org.opencontainers.image.description="Redis in-memory data store" \
      org.opencontainers.image.version="${REDIS_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        libssl3t64 \
        ca-certificates \
        tzdata \
    && groupadd -r -g 1001 redis \
    && useradd -r -u 1001 -g redis -d /data redis \
    && mkdir -p /data /opt/redis/etc \
    && chown -R redis:redis /data /opt/redis \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/redis/bin/ /opt/redis/bin/
COPY rootfs/entrypoint.sh /opt/redis/entrypoint.sh

RUN chmod +x /opt/redis/entrypoint.sh \
    && ln -s /opt/redis/bin/* /usr/local/bin/

ENV REDIS_PORT="6379" \
    REDIS_EXTRA_FLAGS="" \
    REDIS_DISABLE_COMMANDS="" \
    PATH="/opt/redis/bin:${PATH}"

VOLUME ["/data"]
WORKDIR /data
EXPOSE 6379

USER 1001
ENTRYPOINT ["/opt/redis/entrypoint.sh"]
CMD ["redis-server"]
