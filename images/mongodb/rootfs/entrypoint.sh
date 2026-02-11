#!/bin/bash
set -e

DATADIR="${MONGODB_DATA_DIR:-/data/mongodb/data}"
LOGDIR="${MONGODB_LOG_DIR:-/data/mongodb/logs}"

needs_init() {
    [ -n "$MONGODB_ROOT_PASSWORD" ] && return 0
    [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ] && [ -n "$MONGODB_DATABASE" ] && return 0
    for f in /docker-entrypoint-initdb.d/*; do [ -f "$f" ] && return 0; done
    return 1
}

setup_keyfile() {
    if [ -z "$MONGODB_KEYFILE_PATH" ]; then
        echo "ERROR: MONGODB_KEYFILE_PATH is required for replica set mode"
        exit 1
    fi
    if [ ! -f "$MONGODB_KEYFILE_PATH" ]; then
        echo "ERROR: Keyfile not found at $MONGODB_KEYFILE_PATH"
        exit 1
    fi
    echo "Keyfile found at $MONGODB_KEYFILE_PATH"
}

wait_for_tcp() {
    local port="$1"
    local timeout="${2:-120}"
    echo "Waiting for mongod on port $port..."
    for i in $(seq 1 "$timeout"); do
        if bash -c "echo > /dev/tcp/127.0.0.1/$port" 2>/dev/null; then
            echo "mongod is accepting connections."
            sleep 2
            return 0
        fi
        if [ "$i" -eq "$timeout" ]; then
            echo "ERROR: mongod did not start in ${timeout}s"
            return 1
        fi
        sleep 2
    done
}

wait_for_host() {
    local host="$1"
    local port="$2"
    local timeout="${3:-300}"
    echo "Waiting for $host:$port..."
    for i in $(seq 1 "$timeout"); do
        if bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
            echo "$host:$port is reachable."
            return 0
        fi
        sleep 2
    done
    echo "ERROR: $host:$port not reachable after ${timeout}s"
    return 1
}

init_replicaset() {
    local port="${MONGODB_PORT:-27017}"
    local init_marker="$DATADIR/.mongodb_rs_init_complete"

    if [ -f "$init_marker" ]; then
        echo "Replica set already initialized, skipping."
        return
    fi

    echo "Initializing MongoDB replica set..."

    # Start mongod with --replSet and --keyFile in background
    # The localhost exception allows rs.initiate() and first user creation without auth
    mongod --dbpath "$DATADIR" --port "$port" --bind_ip_all \
        --replSet "${MONGODB_REPLICA_SET_NAME:-rs0}" \
        --keyFile "${MONGODB_KEYFILE_PATH}" \
        --logpath "$LOGDIR/mongod_init.log" &
    local pid=$!

    wait_for_tcp "$port" 120 || { kill "$pid" 2>/dev/null; exit 1; }

    # Wait for all secondary hosts to be reachable before rs.initiate()
    if [ -n "$MONGODB_SECONDARY_HOSTS" ]; then
        IFS=',' read -ra HOSTS <<< "$MONGODB_SECONDARY_HOSTS"
        for host in "${HOSTS[@]}"; do
            wait_for_host "$host" "$port" 300 || { kill "$pid" 2>/dev/null; exit 1; }
        done
    fi

    # Build replica set member config
    local rs_members="[{_id: 0, host: '${MONGODB_INITIAL_PRIMARY_HOST}:${port}', priority: 2}"
    local member_id=1
    if [ -n "$MONGODB_SECONDARY_HOSTS" ]; then
        IFS=',' read -ra HOSTS <<< "$MONGODB_SECONDARY_HOSTS"
        for host in "${HOSTS[@]}"; do
            rs_members="${rs_members}, {_id: ${member_id}, host: '${host}:${port}'}"
            member_id=$((member_id + 1))
        done
    fi
    rs_members="${rs_members}]"

    local rs_name="${MONGODB_REPLICA_SET_NAME:-rs0}"

    # rs.initiate() via localhost exception with retry (idempotent)
    for attempt in $(seq 1 5); do
        mongosh --quiet --port "$port" admin <<EOJS && break
try {
  var status = rs.status();
  if (status.ok === 1) {
    print("Replica set already initiated, skipping rs.initiate().");
  }
} catch (e) {
  if (e.codeName === "NotYetInitialized") {
    print("Initiating replica set '${rs_name}' (attempt ${attempt}/5)...");
    rs.initiate({_id: '${rs_name}', members: ${rs_members}});
    print("Replica set initiated.");
  } else { throw e; }
}
EOJS
        echo "rs.initiate() attempt $attempt failed, retrying in 10s..."
        sleep 10
    done

    # Wait for PRIMARY election
    echo "Waiting for PRIMARY election..."
    for i in $(seq 1 120); do
        IS_PRIMARY=$(mongosh --quiet --port "$port" admin --eval "try { db.hello().isWritablePrimary } catch(e) { false }" 2>/dev/null || echo "false")
        if [ "$IS_PRIMARY" = "true" ]; then
            echo "This node is PRIMARY."
            break
        fi
        if [ "$i" -eq 120 ]; then
            echo "ERROR: PRIMARY election timed out"
            kill "$pid" 2>/dev/null || true
            exit 1
        fi
        sleep 2
    done

    # Create root user via localhost exception (idempotent)
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

    # Create app user (localhost exception closed after root user, must auth)
    if [ -n "$MONGODB_USERNAME" ] && [ -n "$MONGODB_PASSWORD" ] && [ -n "$MONGODB_DATABASE" ]; then
        mongosh --quiet --port "$port" \
            -u "${MONGODB_ROOT_USERNAME:-root}" -p "${MONGODB_ROOT_PASSWORD}" \
            --authenticationDatabase admin "${MONGODB_DATABASE}" <<EOJS || true
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

    # Shutdown init mongod
    kill "$pid"
    wait "$pid" 2>/dev/null || true

    touch "$init_marker"
    echo "Replica set initialization complete."
}

init_database() {
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
    mongod \
        --dbpath "$DATADIR" \
        --port "${MONGODB_PORT:-27017}" \
        --bind_ip_all \
        --noauth \
        --logpath "$LOGDIR/mongod.log" &
    local pid=$!

    local port="${MONGODB_PORT:-27017}"
    wait_for_tcp "$port" 120 || { kill "$pid" 2>/dev/null; exit 1; }

    # Create root user (idempotent)
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

    kill "$pid"
    wait "$pid" 2>/dev/null || true

    touch "$init_marker"
    echo "MongoDB initialization complete."
}

if [ "$1" = "mongod" ]; then
    mkdir -p "$DATADIR"
    mkdir -p "$LOGDIR"

    shift

    ARGS="--dbpath $DATADIR --port ${MONGODB_PORT:-27017} --bind_ip_all"

    case "${MONGODB_REPLICA_SET_MODE}" in
        primary)
            setup_keyfile
            init_replicaset
            ARGS="$ARGS --replSet ${MONGODB_REPLICA_SET_NAME:-rs0} --keyFile ${MONGODB_KEYFILE_PATH} --auth"
            echo "Starting MongoDB as replica set PRIMARY (${MONGODB_REPLICA_SET_NAME:-rs0})..."
            ;;
        secondary)
            setup_keyfile
            ARGS="$ARGS --replSet ${MONGODB_REPLICA_SET_NAME:-rs0} --keyFile ${MONGODB_KEYFILE_PATH} --auth"
            echo "Starting MongoDB as replica set SECONDARY (${MONGODB_REPLICA_SET_NAME:-rs0})..."
            ;;
        *)
            init_database
            if [ -n "$MONGODB_ROOT_PASSWORD" ]; then
                ARGS="$ARGS --auth"
            fi
            ;;
    esac

    exec mongod $ARGS $MONGODB_EXTRA_FLAGS "$@"
fi

exec "$@"
