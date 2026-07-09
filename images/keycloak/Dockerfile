# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:b7f48194d4d8b763a478a621cdc81c27be222ba2206ca3ca6bc42b49685f3d9e

ARG KEYCLOAK_VERSION=26.7.0

LABEL org.opencontainers.image.title="keycloak" \
      org.opencontainers.image.description="keycloak packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${KEYCLOAK_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/keycloak/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-21-jre-headless \
        ca-certificates \
        curl \
        tzdata \
        bash \
    && mkdir -p /opt/keycloak \
    && curl -fsSL "https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz" \
        | tar xz --strip-components=1 -C /opt/keycloak \
    && mkdir -p /data/keycloak \
    && groupadd -r -g 1001 keycloak \
    && useradd -r -u 1001 -g keycloak -d /opt/keycloak -s /bin/bash keycloak \
    && chown -R keycloak:keycloak /opt/keycloak /data/keycloak \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/keycloak/entrypoint.sh
RUN chmod +x /opt/keycloak/entrypoint.sh

ENV KC_HTTP_PORT="8080" \
    KC_HTTPS_PORT="8443" \
    KC_DB="dev-file" \
    KC_HEALTH_ENABLED="true" \
    KC_METRICS_ENABLED="true" \
    KC_EXTRA_ARGS="" \
    PATH="/opt/keycloak/bin:${PATH}"

VOLUME ["/data/keycloak"]
EXPOSE 8080 8443 9000

USER 1001
ENTRYPOINT ["/opt/keycloak/entrypoint.sh"]
CMD ["start-dev"]
