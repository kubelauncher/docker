#!/bin/bash
set -e

DATADIR="${MYSQL_DATA_DIR:-/data/mysql/data}"

init_database() {
    if [ -d "$DATADIR/mysql" ]; then
        echo "MySQL data directory already initialized, skipping."
        return
    fi

    echo "Initializing MySQL database..."

    mysqld --initialize-insecure \
        --user=mysql \
        --datadir="$DATADIR"

    mysqld \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock &
    local pid=$!

    for i in $(seq 1 30); do
        if mysql --socket=/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        mysql --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
EOSQL
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        mysql --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
EOSQL
    fi

    if [ -n "$MYSQL_DATABASE" ]; then
        mysql --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
        if [ -n "$MYSQL_USER" ]; then
            mysql --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
EOSQL
        fi
    fi

    mysql --socket=/run/mysqld/mysqld.sock -u root -e "FLUSH PRIVILEGES;"

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
                    local db="${MYSQL_DATABASE:-mysql}"
                    mysql --socket=/run/mysqld/mysqld.sock -u root -D "$db" < "$f"
                    ;;
                *.sql.gz)
                    echo "Running compressed SQL file: $f"
                    local db="${MYSQL_DATABASE:-mysql}"
                    gunzip -c "$f" | mysql --socket=/run/mysqld/mysqld.sock -u root -D "$db"
                    ;;
            esac
        done
    fi
}

if [ "$1" = "mysqld" ]; then
    init_database
    shift
    exec mysqld \
        --user=mysql \
        --datadir="$DATADIR" \
        --port="${MYSQL_PORT_NUMBER:-3306}" \
        --bind-address=0.0.0.0 \
        --socket=/run/mysqld/mysqld.sock \
        $MYSQL_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
