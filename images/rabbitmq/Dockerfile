# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG RABBITMQ_VERSION=4.2.3

LABEL org.opencontainers.image.title="rabbitmq" \
      org.opencontainers.image.description="RabbitMQ message broker" \
      org.opencontainers.image.version="${RABBITMQ_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 rabbitmq \
    && useradd -r -u 1001 -g rabbitmq -d /var/lib/rabbitmq -s /bin/bash rabbitmq \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg bash tzdata \
    && curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key \
        | gpg --dearmor -o /usr/share/keyrings/rabbitmq-erlang.gpg \
    && curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key \
        | gpg --dearmor -o /usr/share/keyrings/rabbitmq-server.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/rabbitmq-erlang.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main" \
        > /etc/apt/sources.list.d/rabbitmq-erlang.list \
    && echo "deb [signed-by=/usr/share/keyrings/rabbitmq-server.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main" \
        > /etc/apt/sources.list.d/rabbitmq-server.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        erlang-base erlang-asn1 erlang-crypto erlang-eldap \
        erlang-ftp erlang-inets erlang-mnesia erlang-os-mon \
        erlang-parsetools erlang-public-key erlang-runtime-tools \
        erlang-snmp erlang-ssl erlang-syntax-tools \
        erlang-tftp erlang-tools erlang-xmerl \
    && apt-get install -y --no-install-recommends rabbitmq-server \
    && rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_prometheus \
    && mkdir -p /data/rabbitmq/conf \
               /data/rabbitmq/data \
               /data/rabbitmq/logs \
    && chown -R rabbitmq:rabbitmq /var/lib/rabbitmq \
                                   /etc/rabbitmq \
                                   /data/rabbitmq \
    && rm -f /var/lib/rabbitmq/.erlang.cookie \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

COPY rootfs/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV RABBITMQ_NODE_TYPE="stats" \
    RABBITMQ_NODE_NAME="rabbit@localhost" \
    RABBITMQ_DEFAULT_USER="guest" \
    RABBITMQ_DEFAULT_PASS="guest" \
    RABBITMQ_DEFAULT_VHOST="/" \
    RABBITMQ_DATA_DIR="/data/rabbitmq/data" \
    RABBITMQ_LOG_DIR="/data/rabbitmq/logs" \
    RABBITMQ_CONF_DIR="/data/rabbitmq/conf" \
    RABBITMQ_PLUGINS="" \
    HOME="/var/lib/rabbitmq"

VOLUME ["/data/rabbitmq"]
EXPOSE 4369 5551 5552 5671 5672 15671 15672 25672

USER 1001
ENTRYPOINT ["entrypoint.sh"]
CMD ["rabbitmq-server"]
