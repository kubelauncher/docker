# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ARG MONGODB_VERSION=8.2

LABEL org.opencontainers.image.title="mongodb" \
      org.opencontainers.image.description="mongodb packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MONGODB_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/mongodb/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 mongodb \
    && useradd -r -u 1001 -g mongodb -d /data/mongodb -s /bin/bash mongodb \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && curl -fsSL "https://www.mongodb.org/static/pgp/server-8.0.asc" \
        | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg \
    && echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/${MONGODB_VERSION} multiverse" \
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
                /opt/mongodb/keyfile \
    && chown -R mongodb:mongodb /data/mongodb \
                                 /docker-entrypoint-initdb.d \
                                 /opt/mongodb \
    && chmod 700 /data/mongodb/data \
    && chmod 700 /opt/mongodb/keyfile \
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
    MONGODB_EXTRA_FLAGS="" \
    MONGODB_REPLICA_SET_MODE="" \
    MONGODB_REPLICA_SET_NAME="rs0" \
    MONGODB_KEYFILE_PATH=""

VOLUME ["/data/mongodb", "/docker-entrypoint-initdb.d"]
EXPOSE 27017

USER 1001
ENTRYPOINT ["/opt/mongodb/entrypoint.sh"]
CMD ["mongod"]
