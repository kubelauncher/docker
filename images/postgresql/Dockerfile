# syntax=docker/dockerfile:1
FROM alpine:3.23

ARG POSTGRESQL_VERSION=17

LABEL org.opencontainers.image.title="postgresql" \
      org.opencontainers.image.description="PostgreSQL relational database" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

RUN apk add --no-cache \
        "postgresql${POSTGRESQL_VERSION}" \
        "postgresql${POSTGRESQL_VERSION}-client" \
        "postgresql${POSTGRESQL_VERSION}-contrib" \
        su-exec \
        tzdata \
        bash \
        nss \
    && mkdir -p /data/postgresql/data \
                /docker-entrypoint-initdb.d \
                /docker-entrypoint-preinitdb.d \
                /opt/postgresql/conf \
                /run/postgresql \
    && addgroup -S -g 1001 postgresql \
    && adduser -S -u 1001 -G postgresql -h /data/postgresql postgresql \
    && chown -R postgresql:postgresql /data/postgresql \
                                       /docker-entrypoint-initdb.d \
                                       /docker-entrypoint-preinitdb.d \
                                       /opt/postgresql \
                                       /run/postgresql \
    && chmod 700 /data/postgresql/data

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
    PATH="/usr/libexec/postgresql${POSTGRESQL_VERSION}:/usr/bin:${PATH}"

VOLUME ["/data/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d"]
EXPOSE 5432

USER 1001
ENTRYPOINT ["/opt/postgresql/entrypoint.sh"]
CMD ["postgres"]
