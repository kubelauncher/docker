# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

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
