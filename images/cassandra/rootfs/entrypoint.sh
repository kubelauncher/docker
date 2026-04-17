#!/bin/bash
set -e

CASSANDRA_HOME="/opt/cassandra"
CASSANDRA_YAML="${CASSANDRA_HOME}/conf/cassandra.yaml"

setup_config() {
    local listen_addr="${CASSANDRA_LISTEN_ADDRESS:-$(hostname -i 2>/dev/null || echo 'localhost')}"
    local broadcast_addr="${CASSANDRA_BROADCAST_ADDRESS:-$listen_addr}"
    local rpc_addr="${CASSANDRA_RPC_ADDRESS:-0.0.0.0}"
    local broadcast_rpc_addr="${CASSANDRA_BROADCAST_RPC_ADDRESS:-$listen_addr}"

    sed -i \
        -e "s/^cluster_name:.*/cluster_name: '${CASSANDRA_CLUSTER_NAME:-Test Cluster}'/" \
        -e "s/^# *listen_address:.*/listen_address: ${listen_addr}/" \
        -e "s/^listen_address:.*/listen_address: ${listen_addr}/" \
        -e "s/^# *broadcast_address:.*/broadcast_address: ${broadcast_addr}/" \
        -e "s/^# *rpc_address:.*/rpc_address: ${rpc_addr}/" \
        -e "s/^rpc_address:.*/rpc_address: ${rpc_addr}/" \
        -e "s/^# *broadcast_rpc_address:.*/broadcast_rpc_address: ${broadcast_rpc_addr}/" \
        -e "s/- seeds:.*/- seeds: \"${CASSANDRA_SEEDS:-$listen_addr}\"/" \
        -e "s|/var/lib/cassandra/data|${CASSANDRA_DATA_DIR:-/data/cassandra/data}|g" \
        -e "s|/var/lib/cassandra/commitlog|${CASSANDRA_COMMITLOG_DIR:-/data/cassandra/commitlog}|g" \
        -e "s|/var/lib/cassandra/saved_caches|/data/cassandra/saved_caches|g" \
        -e "s|/var/lib/cassandra/hints|/data/cassandra/hints|g" \
        "$CASSANDRA_YAML"

    export MAX_HEAP_SIZE="${CASSANDRA_MAX_HEAP_SIZE:-512M}"
    export CASSANDRA_LOG_DIR="/data/cassandra/logs"

    mkdir -p /data/cassandra/data \
             /data/cassandra/commitlog \
             /data/cassandra/saved_caches \
             /data/cassandra/hints \
             /data/cassandra/logs

    # ── Handle node replacement after pod restart (Kubernetes) ──────────
    # When a StatefulSet pod restarts, the cluster gossip may still hold
    # an entry for the pod's IP, causing:
    #   "A node with address /X.X.X.X:7000 already exists, cancelling join"
    #
    # Set CASSANDRA_REPLACE_ADDRESS to the IP to replace, or "auto" to
    # use the current pod IP.  Uses replace_address_first_boot so the
    # flag is ignored on subsequent normal restarts.
    if [ -n "${CASSANDRA_REPLACE_ADDRESS:-}" ]; then
        local replace_ip="$CASSANDRA_REPLACE_ADDRESS"
        if [ "$replace_ip" = "auto" ]; then
            replace_ip="$(hostname -i 2>/dev/null)"
        fi
        if [ -n "$replace_ip" ]; then
            echo "Enabling replace_address_first_boot=${replace_ip}"
            export JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS:-} -Dcassandra.replace_address_first_boot=${replace_ip}"
        fi
    fi
}

if [ "$1" = "cassandra" ]; then
    setup_config
    exec cassandra -f $CASSANDRA_EXTRA_FLAGS
fi

exec "$@"
