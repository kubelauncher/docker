# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:84e77dee7d1bc93fb029a45e3c6cb9d8aa4831ccfcc7103d36e876938d28895b

ARG RABBITMQ_VERSION=4.2.5

LABEL org.opencontainers.image.title="rabbitmq" \
      org.opencontainers.image.description="rabbitmq packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${RABBITMQ_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/rabbitmq/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 rabbitmq \
    && useradd -r -u 1001 -g rabbitmq -d /var/lib/rabbitmq -s /bin/bash rabbitmq \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg bash tzdata \
    && curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" \
        | gpg --dearmor -o /usr/share/keyrings/com.rabbitmq.team.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main" \
        > /etc/apt/sources.list.d/rabbitmq-erlang.list \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main" \
        >> /etc/apt/sources.list.d/rabbitmq-erlang.list \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main" \
        > /etc/apt/sources.list.d/rabbitmq-server.list \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main" \
        >> /etc/apt/sources.list.d/rabbitmq-server.list \
    && apt-get update \
    && ERLANG_PKGS="erlang-base erlang-asn1 erlang-crypto erlang-eldap \
        erlang-ftp erlang-inets erlang-mnesia erlang-os-mon \
        erlang-parsetools erlang-public-key erlang-runtime-tools \
        erlang-snmp erlang-ssl erlang-syntax-tools \
        erlang-tftp erlang-tools erlang-xmerl" \
    && ERLANG_SPECS="" \
    && for pkg in $ERLANG_PKGS; do \
         ver="$(apt-cache madison "$pkg" | awk -F'|' '/rabbitmq.com/ {gsub(/ /,"",$2); print $2; exit}')"; \
         if [ -z "$ver" ]; then echo "ERROR: $pkg not found in RabbitMQ upstream repo" >&2; exit 1; fi; \
         ERLANG_SPECS="$ERLANG_SPECS $pkg=$ver"; \
       done \
    && apt-get install -y --no-install-recommends $ERLANG_SPECS \
    && RABBIT_VER="$(apt-cache madison rabbitmq-server | awk -F'|' '/rabbitmq.com/ {gsub(/ /,"",$2); print $2; exit}')" \
    && case "${RABBIT_VER}" in \
         "${RABBITMQ_VERSION}"|"${RABBITMQ_VERSION}-"*) ;; \
         *) echo "ERROR: upstream ships rabbitmq-server ${RABBIT_VER}, expected ${RABBITMQ_VERSION}" >&2; exit 1 ;; \
       esac \
    && apt-get install -y --no-install-recommends "rabbitmq-server=${RABBIT_VER}" \
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
