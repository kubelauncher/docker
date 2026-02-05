#!/bin/bash
set -e

KAFKA_HOME="/opt/kafka"

# Read all config from env vars FIRST, then unset all KAFKA_* to prevent
# Kafka 3.9+ KIP-719 from interpreting them as config property overrides.
read_config() {
    CFG_LOG_DIRS="${KAFKA_LOG_DIRS:-${KAFKA_CFG_LOG_DIRS:-/data/kafka/data}}"
    CFG_CLUSTER_ID="${KAFKA_CLUSTER_ID:-${KAFKA_KRAFT_CLUSTER_ID}}"
    local raw_id="${KAFKA_BROKER_ID:-${KAFKA_CFG_NODE_ID:-1}}"
    # Extract ordinal from pod name (e.g. "kafka-0" -> "0")
    if [[ "$raw_id" =~ -([0-9]+)$ ]]; then
        CFG_NODE_ID="${BASH_REMATCH[1]}"
    else
        CFG_NODE_ID="$raw_id"
    fi
    CFG_PORT="${KAFKA_PORT:-9092}"
    CFG_CTRL_PORT="${KAFKA_CONTROLLER_PORT:-9093}"
    CFG_HEAP_OPTS="${KAFKA_HEAP_OPTS:--Xmx512m -Xms512m}"

    if [ -n "${KAFKA_ADVERTISED_LISTENERS:-${KAFKA_CFG_ADVERTISED_LISTENERS}}" ]; then
        CFG_ADVERTISED="${KAFKA_ADVERTISED_LISTENERS:-${KAFKA_CFG_ADVERTISED_LISTENERS}}"
    else
        local host
        host="$(hostname 2>/dev/null || echo 'localhost')"
        CFG_ADVERTISED="PLAINTEXT://${host}:${CFG_PORT}"
    fi

    CFG_LISTENERS="${KAFKA_LISTENERS:-${KAFKA_CFG_LISTENERS:-PLAINTEXT://:${CFG_PORT},CONTROLLER://:${CFG_CTRL_PORT}}}"
    CFG_QUORUM_VOTERS="${KAFKA_CFG_CONTROLLER_QUORUM_VOTERS:-${CFG_NODE_ID}@localhost:${CFG_CTRL_PORT}}"
    CFG_PROCESS_ROLES="${KAFKA_CFG_PROCESS_ROLES:-broker,controller}"
    CFG_PROTOCOL_MAP="${KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP:-CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT}"
    CFG_CTRL_LISTENER="${KAFKA_CFG_CONTROLLER_LISTENER_NAMES:-CONTROLLER}"
}

unset_kafka_env() {
    # Unset ALL KAFKA_* env vars. Keep only JVM-related vars.
    for var in $(env | grep '^KAFKA_' | cut -d= -f1); do
        case "$var" in
            KAFKA_HEAP_OPTS|KAFKA_OPTS|KAFKA_GC_LOG_OPTS|KAFKA_JMX_OPTS|KAFKA_LOG4J_OPTS|KAFKA_JVM_PERFORMANCE_OPTS|KAFKA_DEBUG) ;;
            *) unset "$var" ;;
        esac
    done
    # Re-export heap opts from saved value
    export KAFKA_HEAP_OPTS="$CFG_HEAP_OPTS"
}

setup_kraft() {
    read_config
    unset_kafka_env

    if [ -z "$CFG_CLUSTER_ID" ]; then
        if [ ! -f "/data/kafka/.cluster_id" ]; then
            CFG_CLUSTER_ID=$("$KAFKA_HOME/bin/kafka-storage.sh" random-uuid)
            echo "$CFG_CLUSTER_ID" > /data/kafka/.cluster_id
        else
            CFG_CLUSTER_ID=$(cat /data/kafka/.cluster_id)
        fi
    fi

    cat > "$KAFKA_HOME/config/server.properties" <<EOF
process.roles=${CFG_PROCESS_ROLES}
node.id=${CFG_NODE_ID}
controller.quorum.voters=${CFG_QUORUM_VOTERS}
listeners=${CFG_LISTENERS}
advertised.listeners=${CFG_ADVERTISED}
controller.listener.names=${CFG_CTRL_LISTENER}
inter.broker.listener.name=PLAINTEXT
listener.security.protocol.map=${CFG_PROTOCOL_MAP}
log.dirs=${CFG_LOG_DIRS}
num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
EOF

    echo "=== Generated server.properties ==="
    cat "$KAFKA_HOME/config/server.properties"
    echo "=== KAFKA_* env vars remaining ==="
    env | grep '^KAFKA_' || true
    echo "==================================="

    if [ ! -f "${CFG_LOG_DIRS}/meta.properties" ]; then
        "$KAFKA_HOME/bin/kafka-storage.sh" format \
            -t "$CFG_CLUSTER_ID" \
            -c "$KAFKA_HOME/config/server.properties" \
            --ignore-formatted
    fi
}

if [ "$1" = "kafka" ]; then
    setup_kraft
    exec "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties"
fi

exec "$@"
