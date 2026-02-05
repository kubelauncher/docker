#!/bin/bash
set -e

DATADIR="${MYSQL_DATA_DIR:-/data/mysql/data}"

init_database() {
    # Create runtime directories (PVC mount may overwrite them)
    mkdir -p /run/mysqld
    mkdir -p "$DATADIR"

    if [ -d "$DATADIR/mysql" ]; then
        echo "MySQL data directory already initialized, skipping."
        return
    fi

    echo "Initializing MySQL database..."

    mysqld --initialize-insecure \
        --datadir="$DATADIR"

    mysqld \
        --datadir="$DATADIR" \
        --skip-networking \
        --skip-grant-tables \
        --socket=/run/mysqld/mysqld.sock &
    local pid=$!

    for i in $(seq 1 30); do
        if mysql --socket=/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    # Build all SQL statements to execute in a single session.
    # FLUSH PRIVILEGES is required before ALTER USER when --skip-grant-tables is active.
    # After FLUSH PRIVILEGES, the current session keeps full access but new
    # connections enforce auth, so everything must run in one batch.
    local sql="FLUSH PRIVILEGES;"

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        sql="${sql}
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        sql="${sql}
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    fi

    if [ -n "$MYSQL_DATABASE" ]; then
        sql="${sql}
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
        if [ -n "$MYSQL_USER" ]; then
            sql="${sql}
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
        fi
    fi

    sql="${sql}
FLUSH PRIVILEGES;"

    mysql --socket=/run/mysqld/mysqld.sock -u root <<< "$sql"

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
                    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
                        mysql --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" -D "$db" < "$f"
                    else
                        mysql --socket=/run/mysqld/mysqld.sock -u root -D "$db" < "$f"
                    fi
                    ;;
                *.sql.gz)
                    echo "Running compressed SQL file: $f"
                    local db="${MYSQL_DATABASE:-mysql}"
                    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
                        gunzip -c "$f" | mysql --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" -D "$db"
                    else
                        gunzip -c "$f" | mysql --socket=/run/mysqld/mysqld.sock -u root -D "$db"
                    fi
                    ;;
            esac
        done
    fi
}

if [ "$1" = "mysqld" ]; then
    init_database
    shift
    exec mysqld \
        --datadir="$DATADIR" \
        --port="${MYSQL_PORT_NUMBER:-3306}" \
        --bind-address=0.0.0.0 \
        --socket=/run/mysqld/mysqld.sock \
        $MYSQL_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
