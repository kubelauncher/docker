# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

ARG ETCD_VERSION=3.6.8

LABEL org.opencontainers.image.title="etcd" \
      org.opencontainers.image.description="etcd packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${ETCD_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/etcd/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        bash \
        tzdata \
    && ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-${ARCH}.tar.gz" \
        | tar xz --strip-components=1 -C /usr/local/bin \
            etcd-v${ETCD_VERSION}-linux-${ARCH}/etcd \
            etcd-v${ETCD_VERSION}-linux-${ARCH}/etcdctl \
            etcd-v${ETCD_VERSION}-linux-${ARCH}/etcdutl \
    && mkdir -p /data/etcd \
    && groupadd -r -g 1001 etcd \
    && useradd -r -u 1001 -g etcd -d /data/etcd -s /bin/bash etcd \
    && chown -R etcd:etcd /data/etcd \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV ETCD_DATA_DIR="/data/etcd" \
    ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379" \
    ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379" \
    ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380" \
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://127.0.0.1:2380" \
    ETCD_INITIAL_CLUSTER="default=http://127.0.0.1:2380" \
    ETCD_INITIAL_CLUSTER_STATE="new" \
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"

VOLUME ["/data/etcd"]
EXPOSE 2379 2380

USER 1001
ENTRYPOINT ["entrypoint.sh"]
CMD ["etcd"]
