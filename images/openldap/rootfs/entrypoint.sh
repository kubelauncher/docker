#!/bin/bash
set -e

DATADIR="/data/openldap/data"
CONFIGDIR="/data/openldap/config"
RUNDIR="/data/openldap/run"

init_ldap() {
    # Check for a marker file to ensure init completed successfully
    if [ -f "$CONFIGDIR/.init_done" ]; then
        echo "OpenLDAP already initialized, skipping."
        return
    fi

    # Clean up any partial config from failed init
    rm -rf "$CONFIGDIR"/*

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

    local ldapi_socket="$RUNDIR/ldapi"
    local ldapi_url="ldapi://$(echo "$ldapi_socket" | sed 's|/|%2F|g')/"

    # Start a temporary slapd to configure via ldapmodify
    slapd -F "$CONFIGDIR" -h "ldap://127.0.0.1:3890/ ${ldapi_url}" &
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
    ldapadd -Y EXTERNAL -H "$ldapi_url" <<EOF
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

    # Wait for MDB database to be ready
    sleep 1

    # Add base entry via LDAP protocol (ignore if already exists)
    ldapadd -x -H ldap://127.0.0.1:3890/ \
        -D "cn=${LDAP_ADMIN_USERNAME:-admin},${root_dn}" \
        -w "$admin_password" <<EOF 2>&1 || echo "Base entry already exists or add failed"
dn: ${root_dn}
objectClass: top
objectClass: dcObject
objectClass: organization
o: ${organisation}
dc: ${dc}
EOF

    for f in /docker-entrypoint-initdb.d/*.ldif; do
        [ -f "$f" ] || continue
        echo "Loading LDIF: $f"
        ldapadd -x -H ldap://127.0.0.1:3890/ \
            -D "cn=${LDAP_ADMIN_USERNAME:-admin},${root_dn}" \
            -w "$admin_password" -f "$f" || true
    done

    for f in /docker-entrypoint-initdb.d/*.sh; do
        [ -f "$f" ] || continue
        echo "Running init script: $f"
        . "$f"
    done

    # Stop temporary slapd and wait for socket release
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    sleep 1

    # Mark init as complete
    touch "$CONFIGDIR/.init_done"
    echo "OpenLDAP initialization complete."
}

if [ "$1" = "slapd" ]; then
    mkdir -p "$RUNDIR" "$DATADIR" "$CONFIGDIR"
    init_ldap
    shift
    # -d 0 runs slapd in foreground mode (required for Docker)
    exec slapd -d 0 -F "$CONFIGDIR" -h "ldap://0.0.0.0:${LDAP_PORT:-389}/" $LDAP_EXTRA_ARGS "$@"
fi

exec "$@"
