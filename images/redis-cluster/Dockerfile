# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9 AS builder

ARG REDIS_VERSION=8.6.1

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

FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ARG REDIS_VERSION=8.6.1

LABEL org.opencontainers.image.title="redis-cluster" \
      org.opencontainers.image.description="redis-cluster packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${REDIS_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/redis-cluster/README.md"

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
    REDIS_CLUSTER_BUS_PORT="16379" \
    REDIS_CLUSTER_ANNOUNCE_HOSTNAME="" \
    REDIS_CLUSTER_ANNOUNCE_IP="" \
    REDIS_CLUSTER_ANNOUNCE_PORT="" \
    REDIS_CLUSTER_ANNOUNCE_BUS_PORT="" \
    REDIS_MAXMEMORY="" \
    REDIS_MAXMEMORY_POLICY="" \
    REDIS_EXTRA_FLAGS="" \
    PATH="/opt/redis/bin:${PATH}"

VOLUME ["/data"]
WORKDIR /data
EXPOSE 6379 16379

USER 1001
ENTRYPOINT ["/opt/redis/entrypoint.sh"]
CMD ["redis-server"]
