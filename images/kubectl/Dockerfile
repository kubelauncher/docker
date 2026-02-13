# syntax=docker/dockerfile:1
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG KUBECTL_VERSION=1.35.1
ARG TARGETARCH

LABEL org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.description="kubectl packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${KUBECTL_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/kubectl/README.md"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        gettext-base \
        bash \
    && ARCH="${TARGETARCH:-amd64}" \
    && curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
    && echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c - \
    && chmod +x /usr/local/bin/kubectl \
    && rm /tmp/kubectl.sha256 \
    && groupadd -r -g 1001 kubectl \
    && useradd -r -u 1001 -g kubectl -d /home/kubectl -m -s /bin/bash kubectl \
    && mkdir -p /home/kubectl/.kube \
    && chown -R kubectl:kubectl /home/kubectl \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/bin:${PATH}"

USER 1001
WORKDIR /home/kubectl
ENTRYPOINT ["kubectl"]
CMD ["--help"]
