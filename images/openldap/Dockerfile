# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG OPENLDAP_VERSION=2.6.7

LABEL org.opencontainers.image.title="openldap" \
      org.opencontainers.image.description="OpenLDAP directory server" \
      org.opencontainers.image.version="${OPENLDAP_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && groupadd -r -g 1001 openldap \
    && useradd -r -u 1001 -g openldap -d /data/openldap -s /bin/bash openldap \
    && apt-get update && apt-get install -y --no-install-recommends \
        slapd \
        ldap-utils \
        ca-certificates \
        tzdata \
        bash \
    && mkdir -p /data/openldap/data \
                /data/openldap/config \
                /opt/openldap \
                /docker-entrypoint-initdb.d \
    && cp -r /etc/ldap/slapd.d /opt/openldap/default-config \
    && chown -R openldap:openldap /data/openldap \
                                    /opt/openldap \
                                    /docker-entrypoint-initdb.d \
                                    /etc/ldap \
                                    /var/lib/ldap \
                                    /var/run/slapd \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/sbin/policy-rc.d

COPY rootfs/entrypoint.sh /opt/openldap/entrypoint.sh
RUN chmod +x /opt/openldap/entrypoint.sh

ENV LDAP_PORT="389" \
    LDAP_ADMIN_USERNAME="admin" \
    LDAP_ADMIN_PASSWORD="" \
    LDAP_ROOT="dc=example,dc=org" \
    LDAP_ORGANISATION="Example Inc." \
    LDAP_CONFIG_PASSWORD="" \
    LDAP_EXTRA_ARGS=""

VOLUME ["/data/openldap", "/docker-entrypoint-initdb.d"]
EXPOSE 389 636

USER 1001
ENTRYPOINT ["/opt/openldap/entrypoint.sh"]
CMD ["slapd"]
