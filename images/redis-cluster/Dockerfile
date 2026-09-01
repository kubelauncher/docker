# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS builder

ARG REDIS_VERSION=8.10.1

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

FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG REDIS_VERSION=8.10.1

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
    && useradd -r -u 1001 -g redis -G 0 -d /data redis \
    && mkdir -p /data /opt/redis/etc \
    # Support arbitrary user ids (OpenShift): dirs are owned by the root group
    # (GID 0) and group perms mirror the owner, so any UID in group 0 can
    # read/write them. Redis writes its data and runtime config under /data.
    && chown -R 1001:0 /data /opt/redis \
    && chmod -R g=u /data /opt/redis \
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
