# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ARG TARGETARCH
ARG MEMCACHED_EXPORTER_VERSION=0.15.5

LABEL org.opencontainers.image.title="memcached-exporter" \
      org.opencontainers.image.description="memcached-exporter packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MEMCACHED_EXPORTER_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/memcached-exporter/README.md"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL "https://github.com/prometheus/memcached_exporter/releases/download/v${MEMCACHED_EXPORTER_VERSION}/memcached_exporter-${MEMCACHED_EXPORTER_VERSION}.linux-${TARGETARCH}.tar.gz" \
       | tar xz --strip-components=1 -C /usr/local/bin/ memcached_exporter-${MEMCACHED_EXPORTER_VERSION}.linux-${TARGETARCH}/memcached_exporter \
    && chmod +x /usr/local/bin/memcached_exporter \
    && apt-get purge -y --auto-remove ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9150
USER 65534
ENTRYPOINT ["/usr/local/bin/memcached_exporter"]
