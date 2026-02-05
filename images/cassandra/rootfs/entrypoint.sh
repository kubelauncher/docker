#!/bin/bash
set -e

CASSANDRA_HOME="/opt/cassandra"
CASSANDRA_YAML="${CASSANDRA_HOME}/conf/cassandra.yaml"

setup_config() {
    local listen_addr="${CASSANDRA_LISTEN_ADDRESS:-$(hostname -i 2>/dev/null || echo 'localhost')}"
    local broadcast_addr="${CASSANDRA_BROADCAST_ADDRESS:-$listen_addr}"

    sed -i \
        -e "s/^cluster_name:.*/cluster_name: '${CASSANDRA_CLUSTER_NAME:-Test Cluster}'/" \
        -e "s/^# *listen_address:.*/listen_address: ${listen_addr}/" \
        -e "s/^listen_address:.*/listen_address: ${listen_addr}/" \
        -e "s/^# *broadcast_address:.*/broadcast_address: ${broadcast_addr}/" \
        -e "s/^# *rpc_address:.*/rpc_address: ${CASSANDRA_RPC_ADDRESS:-0.0.0.0}/" \
        -e "s/^rpc_address:.*/rpc_address: ${CASSANDRA_RPC_ADDRESS:-0.0.0.0}/" \
        -e "s/- seeds:.*/- seeds: \"${CASSANDRA_SEEDS:-127.0.0.1}\"/" \
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
}

if [ "$1" = "cassandra" ]; then
    setup_config
    exec cassandra -f $CASSANDRA_EXTRA_FLAGS
fi

exec "$@"
