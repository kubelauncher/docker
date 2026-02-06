#!/bin/bash
set -e

DATADIR="${MYSQL_DATA_DIR:-/data/mysql/data}"

LOGDIR="${MYSQL_LOG_DIR:-/data/mysql/logs}"

init_database() {
    # Create runtime and log directories
    mkdir -p /run/mysqld /var/run/mysqld
    mkdir -p "$(dirname "$DATADIR")"
    mkdir -p "$LOGDIR"
    touch "$LOGDIR/error.log"
    chown -R mysql:mysql "$LOGDIR" /run/mysqld /var/run/mysqld || true

    # Check if system tables exist (base initialization done)
    local needs_init=true
    local needs_config=true

    if [ -d "$DATADIR/mysql" ]; then
        needs_init=false
        # Check if we've already configured (marker file)
        if [ -f "$DATADIR/.configured" ]; then
            echo "MySQL already initialized and configured, skipping."
            return
        fi
    fi

    # Do base initialization if needed
    if [ "$needs_init" = "true" ]; then
        echo "Initializing MySQL database..."
        # mysqld --initialize-insecure requires datadir to NOT exist
        # Remove empty datadir if it was pre-created by init container
        if [ -d "$DATADIR" ] && [ -z "$(ls -A "$DATADIR")" ]; then
            rmdir "$DATADIR"
        fi
        mysqld --initialize-insecure --datadir="$DATADIR" --log-error=$LOGDIR/error.log 2>&1
        echo "Initialization complete. Checking error log:"
        cat $LOGDIR/error.log 2>/dev/null | tail -20 || true
    else
        echo "MySQL system tables exist, skipping base initialization."
    fi

    # Configure users and databases
    echo "Configuring MySQL users and databases..."
    echo "Starting mysqld for configuration..."

    mysqld \
        --datadir="$DATADIR" \
        --skip-networking \
        --skip-grant-tables \
        --socket=/var/run/mysqld/mysqld.sock \
        --log-error=$LOGDIR/error.log \
        2>&1 &
    local pid=$!

    echo "Waiting for mysqld to be ready (pid=$pid)..."
    local ready=false
    for i in $(seq 1 60); do
        # Check if process is still running
        if ! kill -0 "$pid" 2>/dev/null; then
            echo "ERROR: mysqld process died (was pid=$pid)"
            echo "Error log contents:"
            cat $LOGDIR/error.log 2>/dev/null || true
            exit 1
        fi
        if mysql --socket=/var/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            echo "mysqld is ready after $i seconds"
            ready=true
            break
        fi
        sleep 1
    done

    if [ "$ready" != "true" ]; then
        echo "ERROR: mysqld failed to become ready within 60 seconds"
        echo "Checking if mysqld process is running..."
        ps aux | grep mysqld || true
        echo "Checking error log..."
        cat $LOGDIR/error.log 2>/dev/null || true
        exit 1
    fi

    # Build all SQL statements to execute in a single session
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

    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<< "$sql"

    run_init_scripts

    # Mark as configured
    touch "$DATADIR/.configured"

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
                        mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" -D "$db" < "$f"
                    else
                        mysql --socket=/var/run/mysqld/mysqld.sock -u root -D "$db" < "$f"
                    fi
                    ;;
                *.sql.gz)
                    echo "Running compressed SQL file: $f"
                    local db="${MYSQL_DATABASE:-mysql}"
                    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
                        gunzip -c "$f" | mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" -D "$db"
                    else
                        gunzip -c "$f" | mysql --socket=/var/run/mysqld/mysqld.sock -u root -D "$db"
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
        --socket=/var/run/mysqld/mysqld.sock \
        $MYSQL_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
