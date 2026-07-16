# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:651ba3fe3a830441e3deaf70fafac40d808a6bd2800a6f2c43130055159f23e6

ARG MYSQL_VERSION=8.4

LABEL org.opencontainers.image.title="mysql" \
      org.opencontainers.image.description="mysql packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${MYSQL_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/mysql/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 mysql \
    && useradd -r -u 1001 -g mysql -d /data/mysql -s /bin/bash mysql \
    && apt-get update \
    && MYSQL_PKG_VER="$(apt-cache madison mysql-server | awk -F'|' 'NR==1 {gsub(/ /,"",$2); print $2}')" \
    && case "${MYSQL_PKG_VER}" in \
         "${MYSQL_VERSION}".*) ;; \
         *) echo "ERROR: upstream ships mysql-server ${MYSQL_PKG_VER}, expected ${MYSQL_VERSION}.x" >&2; exit 1 ;; \
       esac \
    && apt-get install -y --no-install-recommends \
        "mysql-server=${MYSQL_PKG_VER}" \
        "mysql-client=${MYSQL_PKG_VER}" \
        tzdata \
        bash \
    && mkdir -p /data/mysql/data \
                /docker-entrypoint-initdb.d \
                /opt/mysql/conf \
                /run/mysqld \
    && chown -R 1001:1001 /data/mysql \
                           /docker-entrypoint-initdb.d \
                           /opt/mysql \
                           /run/mysqld \
    && chmod 700 /data/mysql/data \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

COPY rootfs/entrypoint.sh /opt/mysql/entrypoint.sh
RUN chmod +x /opt/mysql/entrypoint.sh

ENV MYSQL_PORT_NUMBER="3306" \
    MYSQL_DATA_DIR="/data/mysql/data" \
    MYSQL_DATABASE="" \
    MYSQL_USER="" \
    MYSQL_EXTRA_FLAGS="" \
    MYSQL_REPLICATION_MODE="" \
    MYSQL_REPLICATION_USER="" \
    MYSQL_REPLICATION_PASSWORD="" \
    MYSQL_MASTER_HOST="" \
    MYSQL_MASTER_PORT="3306"

VOLUME ["/data/mysql", "/docker-entrypoint-initdb.d"]
EXPOSE 3306

USER 1001
ENTRYPOINT ["/opt/mysql/entrypoint.sh"]
CMD ["mysqld"]
