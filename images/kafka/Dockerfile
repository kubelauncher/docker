# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG KAFKA_VERSION=3.9.0
ARG SCALA_VERSION=2.13

LABEL org.opencontainers.image.title="kafka" \
      org.opencontainers.image.description="Apache Kafka distributed event streaming platform" \
      org.opencontainers.image.version="${KAFKA_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

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
    && useradd -r -u 1001 -g kafka -d /opt/kafka -s /bin/bash kafka \
    && chown -R kafka:kafka /opt/kafka /data/kafka \
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
