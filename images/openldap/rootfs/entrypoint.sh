#!/bin/bash
set -e

DATADIR="/data/openldap/data"
CONFIGDIR="/data/openldap/config"

init_ldap() {
    if [ -f "$CONFIGDIR/cn=config.ldif" ] || [ -d "$CONFIGDIR/cn=config" ]; then
        echo "OpenLDAP already initialized, skipping."
        return
    fi

    echo "Initializing OpenLDAP..."

    local admin_password="${LDAP_ADMIN_PASSWORD:-admin}"
    local config_password="${LDAP_CONFIG_PASSWORD:-$admin_password}"
    local root_dn="${LDAP_ROOT:-dc=example,dc=org}"
    local organisation="${LDAP_ORGANISATION:-Example Inc.}"

    local hashed_admin_pw
    hashed_admin_pw=$(slappasswd -s "$admin_password")

    local hashed_config_pw
    hashed_config_pw=$(slappasswd -s "$config_password")

    local dc
    dc=$(echo "$root_dn" | sed 's/^dc=//;s/,dc=.*//')

    cat > /tmp/slapd.ldif <<EOF
dn: cn=config
objectClass: olcGlobal
cn: config
olcPidFile: /var/run/slapd/slapd.pid

dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

include: file:///etc/ldap/schema/core.ldif
include: file:///etc/ldap/schema/cosine.ldif
include: file:///etc/ldap/schema/inetorgperson.ldif
include: file:///etc/ldap/schema/nis.ldif

dn: olcDatabase=config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: config
olcRootDN: cn=admin,cn=config
olcRootPW: ${hashed_config_pw}

dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcSuffix: ${root_dn}
olcRootDN: cn=${LDAP_ADMIN_USERNAME:-admin},${root_dn}
olcRootPW: ${hashed_admin_pw}
olcDbDirectory: ${DATADIR}
olcDbMaxSize: 1073741824
olcDbIndex: objectClass eq
olcDbIndex: cn,uid eq
olcDbIndex: member,memberUid eq
EOF

    slapadd -n 0 -F "$CONFIGDIR" -l /tmp/slapd.ldif

    cat > /tmp/base.ldif <<EOF
dn: ${root_dn}
objectClass: top
objectClass: dcObject
objectClass: organization
o: ${organisation}
dc: ${dc}
EOF

    slapadd -F "$CONFIGDIR" -l /tmp/base.ldif

    rm -f /tmp/slapd.ldif /tmp/base.ldif

    for f in /docker-entrypoint-initdb.d/*.ldif; do
        [ -f "$f" ] || continue
        echo "Loading LDIF: $f"
        slapadd -F "$CONFIGDIR" -l "$f"
    done

    for f in /docker-entrypoint-initdb.d/*.sh; do
        [ -f "$f" ] || continue
        echo "Running init script: $f"
        . "$f"
    done
}

if [ "$1" = "slapd" ]; then
    init_ldap
    shift
    exec slapd -F "$CONFIGDIR" -h "ldap://0.0.0.0:${LDAP_PORT:-389}/" -d 0 $LDAP_EXTRA_ARGS "$@"
fi

exec "$@"
