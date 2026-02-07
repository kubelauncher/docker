# syntax=docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6
FROM ubuntu:24.04@sha256:cd1dba651b3080c3686ecf4e3c4220f026b521fb76978881737d24f200828b2b

ARG OPENLDAP_VERSION=2.6.9

LABEL org.opencontainers.image.title="openldap" \
      org.opencontainers.image.description="openldap packaged with love by KubeLauncher" \
      org.opencontainers.image.vendor="KubeLauncher" \
      org.opencontainers.image.version="${OPENLDAP_VERSION}" \
      org.opencontainers.image.source="https://github.com/kubelauncher/docker" \
      org.opencontainers.image.documentation="https://github.com/kubelauncher/docker/blob/main/images/openldap/README.md"

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
    && CONF_LDIF="/opt/openldap/default-config/cn=config/olcDatabase={0}config.ldif" \
    && perl -0777 -i -pe 's/\n //g' "$CONF_LDIF" \
    && sed -i '/^# CRC32/d' "$CONF_LDIF" \
    && sed -i 's|by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by \* break|by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by dn.exact=gidNumber=1001+uidNumber=1001,cn=peercred,cn=external,cn=auth manage by * break|' "$CONF_LDIF" \
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
    LDAP_ROOT="dc=example,dc=org" \
    LDAP_ORGANISATION="Example Inc." \
    LDAP_EXTRA_ARGS=""

VOLUME ["/data/openldap", "/docker-entrypoint-initdb.d"]
EXPOSE 389 636

USER 1001
ENTRYPOINT ["/opt/openldap/entrypoint.sh"]
CMD ["slapd"]
