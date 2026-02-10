#!/bin/bash
set -e

DATADIR="${MONGODB_DATA_DIR:-/data/mongodb/data}"
LOGDIR="${MONGODB_LOG_DIR:-/data/mongodb/logs}"

init_database() {
    # Create runtime directories (PVC mount may overwrite them)
    mkdir -p "$DATADIR"
    mkdir -p "$LOGDIR"

    if [ -f "$DATADIR/WiredTiger" ]; then
        echo "MongoDB data directory already initialized, skipping."
        return
    fi

    echo "Initializing MongoDB..."

    # Start mongod in background (not --fork which requires root for some operations)
    mongod \
        --dbpath "$DATADIR" \
        --port "${MONGODB_PORT:-27017}" \
        --bind_ip 127.0.0.1 \
        --noauth \
        --logpath "$LOGDIR/mongod.log" &
    local pid=$!

    # Wait for mongod to accept connections (TCP check first, then mongosh)
    local port="${MONGODB_PORT:-27017}"
    echo "Waiting for mongod to start on port $port..."
    for i in $(seq 1 60); do
        if mongosh --quiet --port "$port" --serverSelectionTimeoutMS 5000 --eval "db.adminCommand('ping')" &>/dev/null; then
            echo "mongod is ready."
            break
        fi
        if [ "$i" -eq 60 ]; then
            echo "ERROR: mongod did not start in time"
            exit 1
        fi
        sleep 2
    done

    if [ -n "$MONGODB_ROOT_PASSWORD" ]; then
        mongosh --port "${MONGODB_PORT:-27017}" admin <<EOJS
db.createUser({
  user: "${MONGODB_ROOT_USERNAME:-root}",
  pwd: "${MONGODB_ROOT_PASSWORD}",
  roles: [{ role: "root", db: "admin" }]
});
EOJS
    fi

    if [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ] && [ -n "$MONGODB_DATABASE" ]; then
        mongosh --port "${MONGODB_PORT:-27017}" "$MONGODB_DATABASE" <<EOJS
db.createUser({
  user: "${MONGODB_USERNAME}",
  pwd: "${MONGODB_PASSWORD}",
  roles: [{ role: "readWrite", db: "${MONGODB_DATABASE}" }]
});
EOJS
    fi

    for f in /docker-entrypoint-initdb.d/*; do
        [ -f "$f" ] || continue
        case "$f" in
            *.sh)
                echo "Running init script: $f"
                . "$f"
                ;;
            *.js)
                echo "Running JS file: $f"
                mongosh --port "${MONGODB_PORT:-27017}" "${MONGODB_DATABASE:-admin}" "$f"
                ;;
        esac
    done

    # Shutdown MongoDB gracefully
    kill "$pid"
    wait "$pid" 2>/dev/null || true

    echo "MongoDB initialization complete."
}

if [ "$1" = "mongod" ]; then
    init_database
    shift

    ARGS="--dbpath $DATADIR --port ${MONGODB_PORT:-27017} --bind_ip_all"

    if [ -n "$MONGODB_ROOT_PASSWORD" ]; then
        ARGS="$ARGS --auth"
    fi

    exec mongod $ARGS $MONGODB_EXTRA_FLAGS "$@"
fi

exec "$@"
