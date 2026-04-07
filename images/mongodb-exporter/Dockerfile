# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:84e77dee7d1bc93fb029a45e3c6cb9d8aa4831ccfcc7103d36e876938d28895b

ARG TARGETARCH
ARG MONGODB_EXPORTER_VERSION=0.47.2

LABEL org.opencontainers.image.title="mongodb-exporter" \
      org.opencontainers.image.description="mongodb-exporter packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MONGODB_EXPORTER_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/mongodb-exporter/README.md"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL "https://github.com/percona/mongodb_exporter/releases/download/v${MONGODB_EXPORTER_VERSION}/mongodb_exporter-${MONGODB_EXPORTER_VERSION}.linux-${TARGETARCH}.tar.gz" \
       | tar xz --strip-components=1 -C /usr/local/bin/ mongodb_exporter-${MONGODB_EXPORTER_VERSION}.linux-${TARGETARCH}/mongodb_exporter \
    && chmod +x /usr/local/bin/mongodb_exporter \
    && apt-get purge -y --auto-remove ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 9216
USER 65534
ENTRYPOINT ["/usr/local/bin/mongodb_exporter"]
