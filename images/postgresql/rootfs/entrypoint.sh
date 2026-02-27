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

    if [ -n "$POSTGRESQL_PG_HBA" ]; then
        echo "Using custom pg_hba.conf from POSTGRESQL_PG_HBA..."
        echo "$POSTGRESQL_PG_HBA" > "$PGDATA/pg_hba.conf"
    else
        cat >> "$PGDATA/pg_hba.conf" <<EOF
host all all 0.0.0.0/0 md5
host all all ::/0 md5
EOF
    fi

    # Add replication entries to pg_hba.conf if replication mode
    if [ "$POSTGRESQL_REPLICATION_MODE" = "master" ]; then
        cat >> "$PGDATA/pg_hba.conf" <<EOF
host replication ${POSTGRESQL_REPLICATION_USER:-repl_user} 0.0.0.0/0 md5
host replication ${POSTGRESQL_REPLICATION_USER:-repl_user} ::/0 md5
EOF
    fi

    cat >> "$PGDATA/postgresql.conf" <<EOF
listen_addresses = '*'
port = ${POSTGRESQL_PORT_NUMBER:-5432}
EOF

    # Add WAL/replication settings for primary
    if [ "$POSTGRESQL_REPLICATION_MODE" = "master" ]; then
        cat >> "$PGDATA/postgresql.conf" <<EOF
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
hot_standby = on
EOF
    fi

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

    # Create replication user if in master mode
    if [ "$POSTGRESQL_REPLICATION_MODE" = "master" ] && [ -n "$POSTGRESQL_REPLICATION_USER" ] && [ -n "$POSTGRESQL_REPLICATION_PASSWORD" ]; then
        echo "Creating replication user: $POSTGRESQL_REPLICATION_USER"
        psql -U postgres -c "CREATE USER \"${POSTGRESQL_REPLICATION_USER}\" WITH REPLICATION PASSWORD '${POSTGRESQL_REPLICATION_PASSWORD}';"
    fi

    run_init_scripts

    pg_stop_temp
}

init_replica() {
    if [ -s "$PGDATA/PG_VERSION" ]; then
        echo "PostgreSQL replica data directory already initialized, skipping."
        return
    fi

    echo "Initializing PostgreSQL replica from ${POSTGRESQL_PRIMARY_HOST}:${POSTGRESQL_PRIMARY_PORT:-5432}..."

    local primary_host="${POSTGRESQL_PRIMARY_HOST}"
    local primary_port="${POSTGRESQL_PRIMARY_PORT:-5432}"
    local repl_user="${POSTGRESQL_REPLICATION_USER:-repl_user}"
    local repl_pass="${POSTGRESQL_REPLICATION_PASSWORD}"

    export PGPASSWORD="$repl_pass"

    for i in $(seq 1 30); do
        if "${PG_BIN_DIR}/pg_isready" -h "$primary_host" -p "$primary_port" -U "$repl_user" &>/dev/null; then
            break
        fi
        echo "Waiting for primary to be ready... ($i/30)"
        sleep 5
    done

    "${PG_BIN_DIR}/pg_basebackup" \
        -h "$primary_host" \
        -p "$primary_port" \
        -U "$repl_user" \
        -D "$PGDATA" \
        -Fp -Xs -R -P

    unset PGPASSWORD

    echo "Replica initialization complete."
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

    if [ "$POSTGRESQL_REPLICATION_MODE" = "slave" ]; then
        init_replica
    else
        init_database
    fi

    # Apply custom postgresql.conf configuration
    if [ -n "$POSTGRESQL_EXTRA_CONF" ]; then
        mkdir -p "$PGDATA/conf.d"
        echo "$POSTGRESQL_EXTRA_CONF" > "$PGDATA/conf.d/custom.conf"
        if ! grep -q "include_dir = 'conf.d'" "$PGDATA/postgresql.conf" 2>/dev/null; then
            echo "include_dir = 'conf.d'" >> "$PGDATA/postgresql.conf"
        fi
    fi

    # PostgreSQL requires 0700 on the data directory
    if [ -d "$PGDATA" ]; then
        chmod 0700 "$PGDATA"
    fi

    shift
    exec "${PG_BIN_DIR}/postgres" -D "$PGDATA" -p "${POSTGRESQL_PORT_NUMBER:-5432}" "$@"
fi

exec "$@"
