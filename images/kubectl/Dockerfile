# syntax=docker/dockerfile:1
FROM alpine:3.23

ARG KUBECTL_VERSION=1.35.0
ARG YQ_VERSION=4.52.2
ARG TARGETARCH

LABEL org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.description="Kubernetes CLI tool" \
      org.opencontainers.image.version="${KUBECTL_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

RUN apk add --no-cache \
        ca-certificates \
        curl \
        git \
        jq \
        gettext \
        bash \
    && ARCH="${TARGETARCH:-amd64}" \
    && curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
    && echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c - \
    && chmod +x /usr/local/bin/kubectl \
    && rm /tmp/kubectl.sha256 \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}" -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && addgroup -S -g 1001 kubectl \
    && adduser -S -u 1001 -G kubectl -h /home/kubectl kubectl \
    && mkdir -p /home/kubectl/.kube \
    && chown -R kubectl:kubectl /home/kubectl \
    && apk del curl

ENV PATH="/usr/local/bin:${PATH}"

USER 1001
WORKDIR /home/kubectl
ENTRYPOINT ["kubectl"]
CMD ["--help"]
