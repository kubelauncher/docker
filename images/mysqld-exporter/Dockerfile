# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

ARG TARGETARCH
ARG MYSQLD_EXPORTER_VERSION=0.18.0

LABEL org.opencontainers.image.title="mysqld-exporter" \
      org.opencontainers.image.description="mysqld-exporter packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MYSQLD_EXPORTER_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/mysqld-exporter/README.md"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL "https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQLD_EXPORTER_VERSION}/mysqld_exporter-${MYSQLD_EXPORTER_VERSION}.linux-${TARGETARCH}.tar.gz" \
       | tar xz --strip-components=1 -C /usr/local/bin/ mysqld_exporter-${MYSQLD_EXPORTER_VERSION}.linux-${TARGETARCH}/mysqld_exporter \
    && chmod +x /usr/local/bin/mysqld_exporter \
    && apt-get purge -y --auto-remove ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9104
USER 65534
ENTRYPOINT ["/usr/local/bin/mysqld_exporter"]
