# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG ZOOKEEPER_VERSION=3.9.3

LABEL org.opencontainers.image.title="zookeeper" \
      org.opencontainers.image.description="Apache ZooKeeper distributed coordination service" \
      org.opencontainers.image.version="${ZOOKEEPER_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless \
        ca-certificates \
        curl \
        tzdata \
        bash \
    && mkdir -p /opt/zookeeper \
    && curl -fsSL "https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" \
        | tar xz --strip-components=1 -C /opt/zookeeper \
    && mkdir -p /data/zookeeper/data \
                /data/zookeeper/logs \
    && groupadd -r -g 1001 zookeeper \
    && useradd -r -u 1001 -g zookeeper -d /opt/zookeeper -s /bin/bash zookeeper \
    && chown -R zookeeper:zookeeper /opt/zookeeper /data/zookeeper \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/zookeeper/entrypoint.sh
RUN chmod +x /opt/zookeeper/entrypoint.sh

ENV ZOO_PORT="2181" \
    ZOO_TICK_TIME="2000" \
    ZOO_INIT_LIMIT="10" \
    ZOO_SYNC_LIMIT="5" \
    ZOO_MAX_CLIENT_CNXNS="60" \
    ZOO_DATA_DIR="/data/zookeeper/data" \
    ZOO_LOG_DIR="/data/zookeeper/logs" \
    ZOO_MY_ID="1" \
    ZOO_SERVERS="" \
    ZOO_HEAP_SIZE="512" \
    PATH="/opt/zookeeper/bin:${PATH}"

VOLUME ["/data/zookeeper"]
EXPOSE 2181 2888 3888

USER 1001
ENTRYPOINT ["/opt/zookeeper/entrypoint.sh"]
CMD ["zookeeper"]
