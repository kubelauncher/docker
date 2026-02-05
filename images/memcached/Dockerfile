# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS builder

ARG MEMCACHED_VERSION=1.6.34

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl libevent-dev \
    && curl -fsSL "https://memcached.org/files/memcached-${MEMCACHED_VERSION}.tar.gz" \
        | tar xz -C /tmp \
    && cd "/tmp/memcached-${MEMCACHED_VERSION}" \
    && ./configure --prefix=/opt/memcached \
    && make -j"$(nproc)" \
    && make install \
    && strip /opt/memcached/bin/memcached \
    && rm -rf /var/lib/apt/lists/*

FROM ubuntu:24.04

ARG MEMCACHED_VERSION=1.6.34

LABEL org.opencontainers.image.title="memcached" \
      org.opencontainers.image.description="Memcached distributed memory caching system" \
      org.opencontainers.image.version="${MEMCACHED_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        libevent-2.1-7t64 ca-certificates tzdata \
    && groupadd -r -g 1001 memcached \
    && useradd -r -u 1001 -g memcached -d /data memcached \
    && mkdir -p /data \
    && chown -R memcached:memcached /data \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/memcached/bin/memcached /usr/local/bin/memcached
COPY rootfs/entrypoint.sh /opt/memcached/entrypoint.sh
RUN chmod +x /opt/memcached/entrypoint.sh

ENV MEMCACHED_PORT="11211" \
    MEMCACHED_MEMORY="64" \
    MEMCACHED_MAX_CONNECTIONS="1024" \
    MEMCACHED_EXTRA_FLAGS=""

EXPOSE 11211

USER 1001
ENTRYPOINT ["/opt/memcached/entrypoint.sh"]
CMD ["memcached"]
