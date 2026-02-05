# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG MYSQL_VERSION=8.4

LABEL org.opencontainers.image.title="mysql" \
      org.opencontainers.image.description="MySQL relational database" \
      org.opencontainers.image.version="${MYSQL_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 \
        | gpg --dearmor -o /usr/share/keyrings/mysql.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] http://repo.mysql.com/apt/ubuntu/ noble mysql-${MYSQL_VERSION}-lts" \
        > /etc/apt/sources.list.d/mysql.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        mysql-server \
        mysql-client \
        tzdata \
        bash \
    && mkdir -p /data/mysql/data \
                /docker-entrypoint-initdb.d \
                /opt/mysql/conf \
                /run/mysqld \
    && groupadd -r -g 1001 mysql-kl \
    && useradd -r -u 1001 -g mysql-kl -d /data/mysql -s /bin/bash mysql-kl \
    && chown -R mysql-kl:mysql-kl /data/mysql \
                                    /docker-entrypoint-initdb.d \
                                    /opt/mysql \
                                    /run/mysqld \
    && chmod 700 /data/mysql/data \
    && apt-get purge -y --auto-remove curl gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/mysql/entrypoint.sh
RUN chmod +x /opt/mysql/entrypoint.sh

ENV MYSQL_PORT_NUMBER="3306" \
    MYSQL_DATA_DIR="/data/mysql/data" \
    MYSQL_DATABASE="" \
    MYSQL_USER="" \
    MYSQL_PASSWORD="" \
    MYSQL_ROOT_PASSWORD="" \
    MYSQL_EXTRA_FLAGS=""

VOLUME ["/data/mysql", "/docker-entrypoint-initdb.d"]
EXPOSE 3306

USER 1001
ENTRYPOINT ["/opt/mysql/entrypoint.sh"]
CMD ["mysqld"]
