#!/bin/bash
set -e

DATADIR="${MARIADB_DATA_DIR:-/data/mariadb/data}"

init_database() {
    if [ -d "$DATADIR/mysql" ]; then
        echo "MariaDB data directory already initialized, skipping."
        return
    fi

    echo "Initializing MariaDB database..."

    mariadb-install-db \
        --user=mariadb \
        --datadir="$DATADIR" \
        --auth-root-authentication-method=normal \
        --skip-test-db

    cat > /tmp/init.sql <<EOSQL
FLUSH PRIVILEGES;
EOSQL

    if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
        cat >> /tmp/init.sql <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
EOSQL
    fi

    if [ -n "$MARIADB_USER" ] && [ -n "$MARIADB_PASSWORD" ]; then
        cat >> /tmp/init.sql <<EOSQL
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
EOSQL
    fi

    if [ -n "$MARIADB_DATABASE" ]; then
        cat >> /tmp/init.sql <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
EOSQL
        if [ -n "$MARIADB_USER" ]; then
            cat >> /tmp/init.sql <<EOSQL
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
EOSQL
        fi
    fi

    cat >> /tmp/init.sql <<EOSQL
FLUSH PRIVILEGES;
EOSQL

    mariadbd \
        --user=mariadb \
        --datadir="$DATADIR" \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock &
    local pid=$!

    for i in $(seq 1 30); do
        if mariadb --socket=/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    mariadb --socket=/run/mysqld/mysqld.sock -u root < /tmp/init.sql
    rm -f /tmp/init.sql

    run_init_scripts

    kill "$pid"
    wait "$pid" 2>/dev/null || true
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
                    local db="${MARIADB_DATABASE:-mysql}"
                    mariadb --socket=/run/mysqld/mysqld.sock -u root -D "$db" < "$f"
                    ;;
                *.sql.gz)
                    echo "Running compressed SQL file: $f"
                    local db="${MARIADB_DATABASE:-mysql}"
                    gunzip -c "$f" | mariadb --socket=/run/mysqld/mysqld.sock -u root -D "$db"
                    ;;
            esac
        done
    fi
}

if [ "$1" = "mariadbd" ]; then
    init_database
    shift
    exec mariadbd \
        --user=mariadb \
        --datadir="$DATADIR" \
        --port="${MARIADB_PORT_NUMBER:-3306}" \
        --bind-address=0.0.0.0 \
        --socket=/run/mysqld/mysqld.sock \
        $MARIADB_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
