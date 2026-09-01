# syntax=docker/dockerfile:1
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG KUBECTL_VERSION=1.37.0
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
    && useradd -r -u 1001 -g kubectl -G 0 -d /home/kubectl -m -s /bin/bash kubectl \
    && mkdir -p /home/kubectl/.kube \
    # Support arbitrary user ids (OpenShift): HOME is owned by the root group
    # (GID 0) and group perms mirror the owner, so any UID in group 0 can write
    # ~/.kube/cache.
    && chown -R 1001:0 /home/kubectl \
    && chmod -R g=u /home/kubectl \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

# HOME is set explicitly so kubectl resolves ~/.kube regardless of the runtime
# UID (an arbitrary OpenShift UID has no passwd entry, hence no home lookup).
ENV PATH="/usr/local/bin:${PATH}" \
    HOME="/home/kubectl"

USER 1001
WORKDIR /home/kubectl
ENTRYPOINT ["kubectl"]
CMD ["--help"]
