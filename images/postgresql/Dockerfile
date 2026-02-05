# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG POSTGRESQL_VERSION=17

LABEL org.opencontainers.image.title="postgresql" \
      org.opencontainers.image.description="PostgreSQL relational database" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 postgres \
    && useradd -r -u 1001 -g postgres -d /data/postgresql -s /bin/bash postgres \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt noble-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "postgresql-${POSTGRESQL_VERSION}" \
        "postgresql-client-${POSTGRESQL_VERSION}" \
        "postgresql-contrib-${POSTGRESQL_VERSION}" \
        tzdata \
        bash \
    && mkdir -p /data/postgresql/data \
                /docker-entrypoint-initdb.d \
                /docker-entrypoint-preinitdb.d \
                /opt/postgresql/conf \
                /run/postgresql \
    && chown -R postgres:postgres /data/postgresql \
                                    /docker-entrypoint-initdb.d \
                                    /docker-entrypoint-preinitdb.d \
                                    /opt/postgresql \
                                    /run/postgresql \
    && chmod 700 /data/postgresql/data \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

COPY rootfs/entrypoint.sh /opt/postgresql/entrypoint.sh
RUN chmod +x /opt/postgresql/entrypoint.sh

ENV POSTGRESQL_PORT_NUMBER="5432" \
    POSTGRESQL_DATA_DIR="/data/postgresql/data" \
    POSTGRESQL_DATABASE="" \
    POSTGRESQL_USERNAME="" \
    POSTGRESQL_PASSWORD="" \
    POSTGRESQL_POSTGRES_PASSWORD="" \
    POSTGRESQL_INITDB_ARGS="" \
    PGDATA="/data/postgresql/data" \
    PATH="/usr/lib/postgresql/${POSTGRESQL_VERSION}/bin:${PATH}"

VOLUME ["/data/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d"]
EXPOSE 5432

USER 1001
ENTRYPOINT ["/opt/postgresql/entrypoint.sh"]
CMD ["postgres"]
