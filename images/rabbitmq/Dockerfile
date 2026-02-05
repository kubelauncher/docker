# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG RABBITMQ_VERSION=4.2.3

LABEL org.opencontainers.image.title="rabbitmq" \
      org.opencontainers.image.description="RabbitMQ message broker" \
      org.opencontainers.image.version="${RABBITMQ_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg bash tzdata xz-utils \
    && curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key \
        | gpg --dearmor -o /usr/share/keyrings/rabbitmq-erlang.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/rabbitmq-erlang.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main" \
        > /etc/apt/sources.list.d/rabbitmq-erlang.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends erlang-nox \
    && mkdir -p /opt/rabbitmq \
    && groupadd -r -g 1001 rabbitmq \
    && useradd -r -u 1001 -g rabbitmq -d /opt/rabbitmq -s /bin/bash rabbitmq \
    && curl -fsSL "https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz" \
        | tar xJ --strip-components=1 -C /opt/rabbitmq \
    && mkdir -p /data/rabbitmq/conf \
                /data/rabbitmq/data \
                /data/rabbitmq/logs \
                /etc/rabbitmq \
    && ln -sf /opt/rabbitmq/sbin/* /usr/local/bin/ \
    && rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_prometheus \
    && chown -R rabbitmq:rabbitmq /opt/rabbitmq \
                                   /data/rabbitmq \
                                   /etc/rabbitmq \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/rabbitmq/entrypoint.sh
RUN chmod +x /opt/rabbitmq/entrypoint.sh

ENV RABBITMQ_NODE_TYPE="stats" \
    RABBITMQ_NODE_NAME="rabbit@localhost" \
    RABBITMQ_DEFAULT_USER="guest" \
    RABBITMQ_DEFAULT_PASS="guest" \
    RABBITMQ_DEFAULT_VHOST="/" \
    RABBITMQ_DATA_DIR="/data/rabbitmq/data" \
    RABBITMQ_LOG_DIR="/data/rabbitmq/logs" \
    RABBITMQ_CONF_DIR="/data/rabbitmq/conf" \
    RABBITMQ_PLUGINS="" \
    HOME="/opt/rabbitmq" \
    PATH="/opt/rabbitmq/sbin:${PATH}"

VOLUME ["/data/rabbitmq"]
EXPOSE 4369 5551 5552 5671 5672 15671 15672 25672

USER 1001
ENTRYPOINT ["/opt/rabbitmq/entrypoint.sh"]
CMD ["rabbitmq-server"]
