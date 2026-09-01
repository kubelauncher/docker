# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG KAFKA_VERSION=3.9.0
ARG SCALA_VERSION=2.13

LABEL org.opencontainers.image.title="kafka" \
      org.opencontainers.image.description="kafka packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${KAFKA_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/kafka/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless \
        ca-certificates \
        curl \
        tzdata \
        bash \
    && mkdir -p /opt/kafka \
    && curl -fsSL "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
        | tar xz --strip-components=1 -C /opt/kafka \
    && mkdir -p /data/kafka/data \
                /data/kafka/logs \
                /opt/kafka/config \
    && groupadd -r -g 1001 kafka \
    && useradd -r -u 1001 -g kafka -G 0 -d /opt/kafka -s /bin/bash kafka \
    # Support arbitrary user ids (OpenShift): dirs are owned by the root group (GID 0)
    # and group perms mirror the owner, so any UID in group 0 can read/write them.
    && chown -R 1001:0 /opt/kafka /data/kafka \
    && chmod -R g=u /opt/kafka /data/kafka \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/entrypoint.sh /opt/kafka/entrypoint.sh
RUN chmod +x /opt/kafka/entrypoint.sh

ENV KAFKA_HEAP_OPTS="-Xmx512m -Xms512m" \
    PATH="/opt/kafka/bin:${PATH}"

VOLUME ["/data/kafka"]
EXPOSE 9092 9093

USER 1001
ENTRYPOINT ["/opt/kafka/entrypoint.sh"]
CMD ["kafka"]
