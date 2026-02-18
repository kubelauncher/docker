# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ARG TARGETARCH
ARG POSTGRES_EXPORTER_VERSION=0.19.0

LABEL org.opencontainers.image.title="postgres-exporter" \
      org.opencontainers.image.description="postgres-exporter packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${POSTGRES_EXPORTER_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/postgres-exporter/README.md"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL "https://github.com/prometheus-community/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION}/postgres_exporter-${POSTGRES_EXPORTER_VERSION}.linux-${TARGETARCH}.tar.gz" \
       | tar xz --strip-components=1 -C /usr/local/bin/ postgres_exporter-${POSTGRES_EXPORTER_VERSION}.linux-${TARGETARCH}/postgres_exporter \
    && chmod +x /usr/local/bin/postgres_exporter \
    && apt-get purge -y --auto-remove ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9187
USER 65534
ENTRYPOINT ["/usr/local/bin/postgres_exporter"]
