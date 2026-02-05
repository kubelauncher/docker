#!/bin/bash
set -e

DATADIR="/data/openldap/data"
CONFIGDIR="/data/openldap/config"

init_ldap() {
    if [ -d "$CONFIGDIR/cn=config" ]; then
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

    # Use the pre-installed default slapd config as a base
    cp -r /opt/openldap/default-config/* "$CONFIGDIR/"

    local ldapi_socket="/var/run/slapd/ldapi"
    local ldapi_url="ldapi://$(echo "$ldapi_socket" | sed 's|/|%2F|g')/"

    # Start a temporary slapd to configure via ldapmodify
    slapd -F "$CONFIGDIR" -h "ldap://127.0.0.1:3890/ ${ldapi_url}" -d 0 &
    local pid=$!

    # Wait for slapd to be ready
    for i in $(seq 1 30); do
        if ldapsearch -x -H ldap://127.0.0.1:3890/ -b "" -s base namingContexts &>/dev/null; then
            break
        fi
        sleep 0.5
    done

    # Set the config admin password
    ldapmodify -Y EXTERNAL -H "$ldapi_url" <<EOF 2>/dev/null || true
dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,cn=config
-
replace: olcRootPW
olcRootPW: ${hashed_config_pw}
EOF

    # Load additional schemas
    ldapadd -Y EXTERNAL -H "$ldapi_url" -f /etc/ldap/schema/cosine.ldif 2>/dev/null || true
    ldapadd -Y EXTERNAL -H "$ldapi_url" -f /etc/ldap/schema/inetorgperson.ldif 2>/dev/null || true
    ldapadd -Y EXTERNAL -H "$ldapi_url" -f /etc/ldap/schema/nis.ldif 2>/dev/null || true

    # Add MDB database for the user's root DN
    ldapadd -Y EXTERNAL -H "$ldapi_url" <<EOF 2>/dev/null
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcSuffix: ${root_dn}
olcRootDN: cn=${LDAP_ADMIN_USERNAME:-admin},${root_dn}
olcRootPW: ${hashed_admin_pw}
olcDbDirectory: ${DATADIR}
olcDbIndex: objectClass eq
olcDbIndex: cn,uid eq
olcDbIndex: member,memberUid eq
EOF

    # Stop temporary slapd
    kill "$pid"
    wait "$pid" 2>/dev/null || true

    # Add base entry using slapadd
    cat > /tmp/base.ldif <<EOF
dn: ${root_dn}
objectClass: top
objectClass: dcObject
objectClass: organization
o: ${organisation}
dc: ${dc}
EOF

    slapadd -F "$CONFIGDIR" -l /tmp/base.ldif
    rm -f /tmp/base.ldif

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
    mkdir -p /var/run/slapd "$DATADIR" "$CONFIGDIR"
    init_ldap
    shift
    exec slapd -F "$CONFIGDIR" -h "ldap://0.0.0.0:${LDAP_PORT:-389}/" -d 0 $LDAP_EXTRA_ARGS "$@"
fi

exec "$@"
