# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG MARIADB_VERSION=11.4

LABEL org.opencontainers.image.title="mariadb" \
      org.opencontainers.image.description="MariaDB relational database" \
      org.opencontainers.image.version="${MARIADB_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL 'https://mariadb.org/mariadb_release_signing_key.pgp' \
        -o /etc/apt/keyrings/mariadb-keyring.pgp \
    && echo "deb [signed-by=/etc/apt/keyrings/mariadb-keyring.pgp] https://deb.mariadb.org/${MARIADB_VERSION}/ubuntu noble main" \
        > /etc/apt/sources.list.d/mariadb.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
        tzdata \
        bash \
    && mkdir -p /data/mariadb/data \
                /docker-entrypoint-initdb.d \
                /opt/mariadb/conf \
                /run/mysqld \
    && groupadd -r -g 1001 mariadb \
    && useradd -r -u 1001 -g mariadb -d /data/mariadb -s /bin/bash mariadb \
    && chown -R mariadb:mariadb /data/mariadb \
                                 /docker-entrypoint-initdb.d \
                                 /opt/mariadb \
                                 /run/mysqld \
    && chmod 700 /data/mariadb/data \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/mariadb/entrypoint.sh
RUN chmod +x /opt/mariadb/entrypoint.sh

ENV MARIADB_PORT_NUMBER="3306" \
    MARIADB_DATA_DIR="/data/mariadb/data" \
    MARIADB_DATABASE="" \
    MARIADB_USER="" \
    MARIADB_EXTRA_FLAGS=""

VOLUME ["/data/mariadb", "/docker-entrypoint-initdb.d"]
EXPOSE 3306

USER 1001
ENTRYPOINT ["/opt/mariadb/entrypoint.sh"]
CMD ["mariadbd"]
