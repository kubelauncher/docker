# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG CASSANDRA_VERSION=5.0.9

LABEL org.opencontainers.image.title="cassandra" \
      org.opencontainers.image.description="cassandra packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${CASSANDRA_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/cassandra/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless \
        ca-certificates \
        curl \
        python3 \
        tzdata \
        bash \
    && mkdir -p /opt/cassandra \
    && curl -fsSL "https://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz" \
        | tar xz --strip-components=1 -C /opt/cassandra \
    && mkdir -p /data/cassandra/data \
                /data/cassandra/commitlog \
                /data/cassandra/saved_caches \
                /data/cassandra/hints \
                /data/cassandra/logs \
    && groupadd -r -g 1001 cassandra \
    && useradd -r -u 1001 -g cassandra -G 0 -d /opt/cassandra -s /bin/bash cassandra \
    # Support arbitrary user ids (OpenShift): dirs are owned by the root group (GID 0)
    # and group perms mirror the owner, so any UID in group 0 can read/write them.
    && chown -R 1001:0 /opt/cassandra /data/cassandra \
    && chmod -R g=u /opt/cassandra /data/cassandra \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/cassandra/entrypoint.sh
RUN chmod +x /opt/cassandra/entrypoint.sh

ENV CASSANDRA_CLUSTER_NAME="Test Cluster" \
    CASSANDRA_SEEDS="" \
    CASSANDRA_LISTEN_ADDRESS="" \
    CASSANDRA_BROADCAST_ADDRESS="" \
    CASSANDRA_RPC_ADDRESS="0.0.0.0" \
    CASSANDRA_PORT="9042" \
    CASSANDRA_STORAGE_PORT="7000" \
    CASSANDRA_DATA_DIR="/data/cassandra/data" \
    CASSANDRA_COMMITLOG_DIR="/data/cassandra/commitlog" \
    CASSANDRA_MAX_HEAP_SIZE="512M" \
    CASSANDRA_EXTRA_FLAGS="" \
    PATH="/opt/cassandra/bin:${PATH}"

VOLUME ["/data/cassandra"]
EXPOSE 7000 7001 7199 9042 9160

USER 1001
ENTRYPOINT ["/opt/cassandra/entrypoint.sh"]
CMD ["cassandra"]
