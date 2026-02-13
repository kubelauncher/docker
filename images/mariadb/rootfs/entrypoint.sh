#!/bin/bash
set -e

DATADIR="${MARIADB_DATA_DIR:-/data/mariadb/data}"

get_server_id() {
    if [ "${MARIADB_REPLICATION_MODE}" = "primary" ]; then
        echo 1
    else
        local ordinal
        ordinal=$(hostname | grep -o '[0-9]*$' || echo 0)
        echo $(( ordinal + 100 ))
    fi
}

wait_for_primary() {
    local host="${MARIADB_MASTER_HOST}"
    local port="${MARIADB_MASTER_PORT:-3306}"
    echo "Waiting for primary at ${host}:${port}..."
    for i in $(seq 1 60); do
        if mariadb -h "$host" -P "$port" -u "$MARIADB_REPLICATION_USER" -p"$MARIADB_REPLICATION_PASSWORD" -e "SELECT 1" &>/dev/null; then
            echo "Primary is ready."
            return 0
        fi
        sleep 2
    done
    echo "ERROR: primary not ready after 120s"
    return 1
}

init_replication_primary() {
    # Add replication user to init SQL
    cat >> /tmp/init.sql <<EOSQL
CREATE USER IF NOT EXISTS '${MARIADB_REPLICATION_USER}'@'%' IDENTIFIED BY '${MARIADB_REPLICATION_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO '${MARIADB_REPLICATION_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
}

init_replication_secondary() {
    mkdir -p /run/mysqld
    mkdir -p "$(dirname "$DATADIR")"

    if [ -d "$DATADIR/mysql" ]; then
        echo "MariaDB data directory already initialized, skipping."
        return
    fi

    if [ -d "$DATADIR" ] && [ -z "$(ls -A "$DATADIR")" ]; then
        rmdir "$DATADIR"
    fi

    echo "Initializing MariaDB secondary..."
    mariadb-install-db \
        --user=mariadb \
        --datadir="$DATADIR" \
        --auth-root-authentication-method=normal \
        --skip-test-db

    local server_id
    server_id=$(get_server_id)

    mariadbd \
        --user=mariadb \
        --datadir="$DATADIR" \
        --skip-networking \
        --socket=/run/mysqld/mysqld.sock \
        --server-id="$server_id" &
    local pid=$!

    for i in $(seq 1 30); do
        if mariadb --socket=/run/mysqld/mysqld.sock -u root -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    # Set root password and clean up default users
    if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
        mariadb --socket=/run/mysqld/mysqld.sock -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '%');
FLUSH PRIVILEGES;
EOSQL
    fi

    # Configure replication
    wait_for_primary
    mariadb --socket=/run/mysqld/mysqld.sock -u root -p"${MARIADB_ROOT_PASSWORD}" <<EOSQL
CHANGE MASTER TO
    MASTER_HOST='${MARIADB_MASTER_HOST}',
    MASTER_PORT=${MARIADB_MASTER_PORT:-3306},
    MASTER_USER='${MARIADB_REPLICATION_USER}',
    MASTER_PASSWORD='${MARIADB_REPLICATION_PASSWORD}',
    MASTER_USE_GTID=slave_pos;
START SLAVE;
EOSQL

    echo "Replication configured, verifying..."
    sleep 2
    mariadb --socket=/run/mysqld/mysqld.sock -u root -p"${MARIADB_ROOT_PASSWORD}" -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Master_Host)"

    kill "$pid"
    wait "$pid" 2>/dev/null || true
}

init_database() {
    # Create runtime directories (PVC mount may overwrite them)
    mkdir -p /run/mysqld
    # Create parent dir only - MariaDB creates the data dir itself
    mkdir -p "$(dirname "$DATADIR")"

    if [ -d "$DATADIR/mysql" ]; then
        echo "MariaDB data directory already initialized, skipping."
        return
    fi

    # Remove empty data dir if it exists (MariaDB needs it to not exist or be empty)
    if [ -d "$DATADIR" ] && [ -z "$(ls -A "$DATADIR")" ]; then
        rmdir "$DATADIR"
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
DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '%');
FLUSH PRIVILEGES;
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

    # Add replication user if primary mode
    if [ "${MARIADB_REPLICATION_MODE}" = "primary" ] && [ -n "$MARIADB_REPLICATION_USER" ]; then
        init_replication_primary
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
    shift
    REPL_FLAGS=""

    case "${MARIADB_REPLICATION_MODE}" in
        primary)
            init_database
            # init_replication_primary was called inside init_database via hook
            REPL_FLAGS="--server-id=1 --log-bin --binlog-format=ROW"
            ;;
        secondary)
            init_replication_secondary
            local_server_id=$(get_server_id)
            REPL_FLAGS="--server-id=${local_server_id} --log-bin --binlog-format=ROW --read-only=1"
            ;;
        *)
            init_database
            ;;
    esac

    exec mariadbd \
        --user=mariadb \
        --datadir="$DATADIR" \
        --port="${MARIADB_PORT_NUMBER:-3306}" \
        --bind-address=0.0.0.0 \
        --socket=/run/mysqld/mysqld.sock \
        --log-warnings=1 \
        --skip-name-resolve \
        $REPL_FLAGS \
        $MARIADB_EXTRA_FLAGS \
        "$@"
fi

exec "$@"
