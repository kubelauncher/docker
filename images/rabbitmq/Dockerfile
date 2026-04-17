# syntax=docker/dockerfile:1
FROM rabbitmq:4.2.5@sha256:d3356b10fd1afd503b58f53d267e9561338501d5ba4e9cf2f62b4250e55fece4

ARG RABBITMQ_VERSION=4.2.5

LABEL org.opencontainers.image.title="rabbitmq" \
      org.opencontainers.image.description="rabbitmq packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${RABBITMQ_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/rabbitmq/README.md"

USER root

# Align rabbitmq UID/GID to KubeLauncher convention (1001) so existing PVCs
# from earlier KubeLauncher images keep working after this rebase.
# Also verify the base image ships the expected RABBITMQ_VERSION to catch
# silent upstream drift.
RUN set -eux \
    && INSTALLED_VERSION="$(rabbitmqctl version 2>/dev/null | tail -1 | tr -d '[:space:]')" \
    && if [ "${INSTALLED_VERSION}" != "${RABBITMQ_VERSION}" ]; then \
         echo "ERROR: base image ships rabbitmq ${INSTALLED_VERSION}, expected ${RABBITMQ_VERSION}" >&2; \
         exit 1; \
       fi \
    && groupmod -g 1001 rabbitmq \
    && usermod -u 1001 -g 1001 rabbitmq \
    && rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_prometheus \
    && mkdir -p /data/rabbitmq/conf \
               /data/rabbitmq/data \
               /data/rabbitmq/logs \
    && chown -R 1001:1001 /var/lib/rabbitmq \
                           /etc/rabbitmq \
                           /data/rabbitmq \
    && rm -f /var/lib/rabbitmq/.erlang.cookie

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
