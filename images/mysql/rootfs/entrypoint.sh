#!/bin/bash
set -e

DATADIR="${MYSQL_DATA_DIR:-/data/mysql/data}"
LOGDIR="${MYSQL_LOG_DIR:-/data/mysql/logs}"

get_server_id() {
    if [ "${MYSQL_REPLICATION_MODE}" = "primary" ]; then
        echo 1
    else
        local ordinal
        ordinal=$(hostname | grep -o '[0-9]*$' || echo 0)
        echo $(( ordinal + 100 ))
    fi
}

wait_for_primary() {
    local host="${MYSQL_MASTER_HOST}"
    local port="${MYSQL_MASTER_PORT:-3306}"
    echo "Waiting for primary at ${host}:${port}..."
    for i in $(seq 1 60); do
        if mysql -h "$host" -P "$port" -u "$MYSQL_REPLICATION_USER" -p"$MYSQL_REPLICATION_PASSWORD" -e "SELECT 1" &>/dev/null; then
            echo "Primary is ready."
            return 0
        fi
        sleep 2
    done
    echo "ERROR: primary not ready after 120s"
    return 1
}

init_replication_primary() {
    cat >> /tmp/init.sql <<EOSQL
CREATE USER IF NOT EXISTS '${MYSQL_REPLICATION_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_REPLICATION_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO '${MYSQL_REPLICATION_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
}

init_replication_secondary() {
    mkdir -p /run/mysqld /var/run/mysqld 2>/dev/null || true
    if ! mkdir -p "$DATADIR" 2>/dev/null || ! touch "$DATADIR/.write-test" 2>/dev/null; then
        DATADIR="/tmp/mysql-data"
        LOGDIR="/tmp/mysql-logs"
    else
        rm -f "$DATADIR/.write-test"
    fi
    if ! mkdir -p "$LOGDIR" 2>/dev/null; then
        LOGDIR="/tmp/mysql-logs"
    fi
    mkdir -p "$DATADIR" "$LOGDIR"
    touch "$LOGDIR/error.log" 2>/dev/null || true
    chown -R mysql:mysql "$LOGDIR" /run/mysqld /var/run/mysqld 2>/dev/null || true

    if [ -f "$DATADIR/.configured" ]; then
        echo "MySQL secondary already configured, skipping."
        return
    fi

    # Initialize data directory
    if [ ! -d "$DATADIR/mysql" ]; then
        echo "Initializing MySQL secondary data directory..."
        if [ -d "$DATADIR" ] && [ -z "$(ls -A "$DATADIR")" ]; then
            rmdir "$DATADIR"
        fi
        mysqld --initialize-insecure --datadir="$DATADIR" --log-error="$LOGDIR/error.log" 2>&1
    fi

    wait_for_primary

    # Start temporary mysqld for configuration (with GTID for MASTER_AUTO_POSITION=1)
    local local_server_id
    local_server_id=$(get_server_id)
    mysqld \
        --datadir="$DATADIR" \
        --skip-networking \
        --skip-grant-tables \
        --socket=/var/run/mysqld/mysqld.sock \
        --log-error="$LOGDIR/error.log" \
        --server-id="$local_server_id" \
        --gtid-mode=ON \
        --enforce-gtid-consistency=ON \
        2>&1 &
    local pid=$!

    for i in $(seq 1 60); do
        if mysql --socket=/var/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    # Set root password, clean up default users, configure replication
    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<EOSQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '%');
FLUSH PRIVILEGES;
CHANGE MASTER TO
    MASTER_HOST='${MYSQL_MASTER_HOST}',
    MASTER_PORT=${MYSQL_MASTER_PORT:-3306},
    MASTER_USER='${MYSQL_REPLICATION_USER}',
    MASTER_PASSWORD='${MYSQL_REPLICATION_PASSWORD}',
    MASTER_AUTO_POSITION=1;
START SLAVE;
FLUSH PRIVILEGES;
EOSQL

    touch "$DATADIR/.configured"
    kill "$pid"
    wait "$pid" 2>/dev/null || true
}

init_database() {
    # Create runtime directories
    mkdir -p /run/mysqld /var/run/mysqld 2>/dev/null || true

    # Test if we can create and write to the data directory itself
    # Note: mysqld --initialize requires DATADIR to NOT exist, so we test then remove it
    if ! mkdir -p "$DATADIR" 2>/dev/null || ! touch "$DATADIR/.write-test" 2>/dev/null; then
        echo "WARNING: Cannot write to $DATADIR, using /tmp for data"
        DATADIR="/tmp/mysql-data"
        LOGDIR="/tmp/mysql-logs"
    else
        rm -f "$DATADIR/.write-test"
    fi

    # Create log directory (may also need fallback)
    if ! mkdir -p "$LOGDIR" 2>/dev/null; then
        LOGDIR="/tmp/mysql-logs"
    fi
    mkdir -p "$DATADIR" "$LOGDIR"

    touch "$LOGDIR/error.log" 2>/dev/null || true
    chown -R mysql:mysql "$LOGDIR" /run/mysqld /var/run/mysqld 2>/dev/null || true

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

    # Build init SQL file
    cat > /tmp/init.sql <<EOSQL
FLUSH PRIVILEGES;
EOSQL

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        cat >> /tmp/init.sql <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '%');
FLUSH PRIVILEGES;
EOSQL
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        cat >> /tmp/init.sql <<EOSQL
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
EOSQL
    fi

    if [ -n "$MYSQL_DATABASE" ]; then
        cat >> /tmp/init.sql <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
        if [ -n "$MYSQL_USER" ]; then
            cat >> /tmp/init.sql <<EOSQL
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
EOSQL
        fi
    fi

    # Add replication user if in primary mode
    if [ "${MYSQL_REPLICATION_MODE}" = "primary" ] && [ -n "$MYSQL_REPLICATION_USER" ]; then
        init_replication_primary
    fi

    cat >> /tmp/init.sql <<EOSQL
FLUSH PRIVILEGES;
EOSQL

    mysql --socket=/var/run/mysqld/mysqld.sock -u root < /tmp/init.sql
    rm -f /tmp/init.sql

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

REPL_FLAGS=""

if [ "$1" = "mysqld" ]; then
    case "${MYSQL_REPLICATION_MODE}" in
        primary)
            init_database
            REPL_FLAGS="--server-id=1 --log-bin --gtid-mode=ON --enforce-gtid-consistency=ON --binlog-format=ROW"
            ;;
        secondary)
            init_replication_secondary
            local_server_id=$(get_server_id)
            REPL_FLAGS="--server-id=${local_server_id} --log-bin --gtid-mode=ON --enforce-gtid-consistency=ON --binlog-format=ROW --read-only=1"
            ;;
        *)
            init_database
            ;;
    esac
    # Apply custom my.cnf configuration
    EXTRA_FILE_FLAG=""
    if [ -n "$MYSQL_EXTRA_CONF" ]; then
        printf '[mysqld]\n%s\n' "$MYSQL_EXTRA_CONF" > /tmp/custom.cnf
        EXTRA_FILE_FLAG="--defaults-extra-file=/tmp/custom.cnf"
    fi

    shift
    exec mysqld \
        $EXTRA_FILE_FLAG \
        --datadir="$DATADIR" \
        --port="${MYSQL_PORT_NUMBER:-3306}" \
        --bind-address=0.0.0.0 \
        --socket=/var/run/mysqld/mysqld.sock \
        --log-error-verbosity=1 \
        --skip-name-resolve \
        $REPL_FLAGS \
        $MYSQL_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
