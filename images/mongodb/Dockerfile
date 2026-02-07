# syntax=docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG MONGODB_VERSION=8.2

LABEL org.opencontainers.image.title="mongodb" \
      org.opencontainers.image.description="mongodb packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MONGODB_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/mongodb/README.md"

ENV DEBIAN_FRONTEND=noninteractive

# Extract major version (e.g., 8.0 from 8.2) for MongoDB repo
ARG MONGODB_MAJOR_VERSION=8.0

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 mongodb \
    && useradd -r -u 1001 -g mongodb -d /data/mongodb -s /bin/bash mongodb \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && curl -fsSL "https://www.mongodb.org/static/pgp/server-${MONGODB_MAJOR_VERSION}.asc" \
        | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg \
    && echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/${MONGODB_MAJOR_VERSION} multiverse" \
        > /etc/apt/sources.list.d/mongodb.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        mongodb-org \
        tzdata \
        bash \
    && mkdir -p /data/mongodb/data \
                /data/mongodb/logs \
                /docker-entrypoint-initdb.d \
                /opt/mongodb \
    && chown -R mongodb:mongodb /data/mongodb \
                                 /docker-entrypoint-initdb.d \
                                 /opt/mongodb \
    && chmod 700 /data/mongodb/data \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/mongodb/entrypoint.sh
RUN chmod +x /opt/mongodb/entrypoint.sh

ENV MONGODB_PORT="27017" \
    MONGODB_DATA_DIR="/data/mongodb/data" \
    MONGODB_LOG_DIR="/data/mongodb/logs" \
    MONGODB_DATABASE="" \
    MONGODB_USERNAME="" \
    MONGODB_ROOT_USERNAME="root" \
    MONGODB_EXTRA_FLAGS=""

VOLUME ["/data/mongodb", "/docker-entrypoint-initdb.d"]
EXPOSE 27017

USER 1001
ENTRYPOINT ["/opt/mongodb/entrypoint.sh"]
CMD ["mongod"]
