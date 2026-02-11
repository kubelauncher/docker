#!/bin/bash
set -e

DATADIR="${MONGODB_DATA_DIR:-/data/mongodb/data}"
LOGDIR="${MONGODB_LOG_DIR:-/data/mongodb/logs}"

needs_init() {
    # Check if any initialization work is needed
    [ -n "$MONGODB_ROOT_PASSWORD" ] && return 0
    [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ] && [ -n "$MONGODB_DATABASE" ] && return 0
    for f in /docker-entrypoint-initdb.d/*; do [ -f "$f" ] && return 0; done
    return 1
}

init_database() {
    # Create runtime directories (PVC mount may overwrite them)
    mkdir -p "$DATADIR"
    mkdir -p "$LOGDIR"

    local init_marker="$DATADIR/.mongodb_init_complete"

    if [ -f "$init_marker" ]; then
        echo "MongoDB already initialized, skipping."
        return
    fi

    if ! needs_init; then
        echo "No users or init scripts to configure, skipping init."
        touch "$init_marker"
        return
    fi

    echo "Initializing MongoDB..."

    # Bind to 0.0.0.0 so kubelet probes can reach mongod during init
    # (pod is not Ready yet so the Service won't route traffic)
    mongod \
        --dbpath "$DATADIR" \
        --port "${MONGODB_PORT:-27017}" \
        --bind_ip_all \
        --noauth \
        --logpath "$LOGDIR/mongod.log" &
    local pid=$!

    # Wait for mongod to accept TCP connections (lightweight check, no mongosh to avoid OOM)
    local port="${MONGODB_PORT:-27017}"
    echo "Waiting for mongod to start on port $port..."
    for i in $(seq 1 60); do
        if bash -c "echo > /dev/tcp/127.0.0.1/$port" 2>/dev/null; then
            echo "mongod is accepting connections."
            sleep 2  # give mongod a moment to finish initialization
            break
        fi
        if [ "$i" -eq 60 ]; then
            echo "ERROR: mongod did not start in time"
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
            exit 1
        fi
        sleep 2
    done

    # Create root user (idempotent — ignores error if user already exists from partial init)
    if [ -n "$MONGODB_ROOT_PASSWORD" ]; then
        mongosh --quiet --port "$port" admin <<EOJS || true
try {
  db.createUser({
    user: "${MONGODB_ROOT_USERNAME:-root}",
    pwd: "${MONGODB_ROOT_PASSWORD}",
    roles: [{ role: "root", db: "admin" }]
  });
  print("Root user created.");
} catch (e) {
  if (e.codeName === "DuplicateKey" || e.code === 51003) {
    print("Root user already exists, skipping.");
  } else { throw e; }
}
EOJS
    fi

    # Create app user (idempotent)
    if [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ] && [ -n "$MONGODB_DATABASE" ]; then
        mongosh --quiet --port "$port" "$MONGODB_DATABASE" <<EOJS || true
try {
  db.createUser({
    user: "${MONGODB_USERNAME}",
    pwd: "${MONGODB_PASSWORD}",
    roles: [{ role: "readWrite", db: "${MONGODB_DATABASE}" }]
  });
  print("App user created.");
} catch (e) {
  if (e.codeName === "DuplicateKey" || e.code === 51003) {
    print("App user already exists, skipping.");
  } else { throw e; }
}
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
                mongosh --quiet --port "$port" "${MONGODB_DATABASE:-admin}" "$f"
                ;;
        esac
    done

    # Shutdown MongoDB gracefully
    kill "$pid"
    wait "$pid" 2>/dev/null || true

    # Only mark init complete AFTER everything succeeded
    touch "$init_marker"
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
