#!/bin/bash
set -e

PG_BIN_DIR="/usr/lib/postgresql/${POSTGRESQL_VERSION:-17}/bin"
PGDATA="${POSTGRESQL_DATA_DIR:-/data/postgresql/data}"
export PGDATA

run_preinit_scripts() {
    if [ -d /docker-entrypoint-preinitdb.d/ ]; then
        for f in /docker-entrypoint-preinitdb.d/*.sh; do
            [ -f "$f" ] || continue
            echo "Running pre-init script: $f"
            . "$f"
        done
    fi
}

init_database() {
    if [ -s "$PGDATA/PG_VERSION" ]; then
        echo "PostgreSQL data directory already initialized, skipping."
        return
    fi

    echo "Initializing PostgreSQL database..."

    local initdb_args=("--pgdata=$PGDATA" "--auth=md5" "--auth-local=trust")
    if [ -n "$POSTGRESQL_INITDB_ARGS" ]; then
        initdb_args+=($POSTGRESQL_INITDB_ARGS)
    fi

    if [ -n "$POSTGRESQL_POSTGRES_PASSWORD" ]; then
        local pwfile
        pwfile=$(mktemp)
        echo "$POSTGRESQL_POSTGRES_PASSWORD" > "$pwfile"
        initdb_args+=("--pwfile=$pwfile")
    fi

    "${PG_BIN_DIR}/initdb" "${initdb_args[@]}"

    [ -n "$pwfile" ] && rm -f "$pwfile"

    cat >> "$PGDATA/pg_hba.conf" <<EOF
host all all 0.0.0.0/0 md5
host all all ::/0 md5
EOF

    cat >> "$PGDATA/postgresql.conf" <<EOF
listen_addresses = '*'
port = ${POSTGRESQL_PORT_NUMBER:-5432}
EOF

    pg_start_temp

    if [ -n "$POSTGRESQL_USERNAME" ] && [ -n "$POSTGRESQL_PASSWORD" ]; then
        echo "Creating user: $POSTGRESQL_USERNAME"
        psql -U postgres -c "CREATE USER \"${POSTGRESQL_USERNAME}\" WITH PASSWORD '${POSTGRESQL_PASSWORD}';"
    fi

    if [ -n "$POSTGRESQL_DATABASE" ]; then
        echo "Creating database: $POSTGRESQL_DATABASE"
        local owner="postgres"
        [ -n "$POSTGRESQL_USERNAME" ] && owner="$POSTGRESQL_USERNAME"
        psql -U postgres -c "CREATE DATABASE \"${POSTGRESQL_DATABASE}\" OWNER \"${owner}\";"
    fi

    run_init_scripts

    pg_stop_temp
}

pg_start_temp() {
    "${PG_BIN_DIR}/pg_ctl" -D "$PGDATA" -o "-p ${POSTGRESQL_PORT_NUMBER:-5432} -c listen_addresses='' -c log_statement=none" -w start >/dev/null
}

pg_stop_temp() {
    "${PG_BIN_DIR}/pg_ctl" -D "$PGDATA" -m fast -w stop >/dev/null
}

run_init_scripts() {
    if [ -d /docker-entrypoint-initdb.d/ ]; then
        for f in /docker-entrypoint-initdb.d/*; do
            [ -f "$f" ] || continue
            case "$f" in
                *.sh)
                    echo "Running init script: $f"
                    . "$f"
                    ;;
                *.sql)
                    echo "Running SQL file: $f"
                    local db="${POSTGRESQL_DATABASE:-postgres}"
                    psql -U postgres -d "$db" -f "$f"
                    ;;
                *.sql.gz)
                    echo "Running compressed SQL file: $f"
                    local db="${POSTGRESQL_DATABASE:-postgres}"
                    gunzip -c "$f" | psql -U postgres -d "$db"
                    ;;
            esac
        done
    fi
}

if [ "$1" = "postgres" ]; then
    run_preinit_scripts
    init_database
    shift
    exec "${PG_BIN_DIR}/postgres" -D "$PGDATA" -p "${POSTGRESQL_PORT_NUMBER:-5432}" "$@"
fi

exec "$@"
