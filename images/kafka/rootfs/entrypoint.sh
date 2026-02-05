#!/bin/bash
set -e

KAFKA_HOME="/opt/kafka"
LOG_DIRS="${KAFKA_LOG_DIRS:-/data/kafka/data}"

setup_kraft() {
    local cluster_id="${KAFKA_CLUSTER_ID}"
    if [ -z "$cluster_id" ]; then
        if [ ! -f "/data/kafka/.cluster_id" ]; then
            cluster_id=$("$KAFKA_HOME/bin/kafka-storage.sh" random-uuid)
            echo "$cluster_id" > /data/kafka/.cluster_id
        else
            cluster_id=$(cat /data/kafka/.cluster_id)
        fi
    fi

    local node_id="${KAFKA_BROKER_ID:-1}"
    local port="${KAFKA_PORT:-9092}"
    local ctrl_port="${KAFKA_CONTROLLER_PORT:-9093}"
    local advertised
    if [ -n "$KAFKA_ADVERTISED_LISTENERS" ]; then
        advertised="$KAFKA_ADVERTISED_LISTENERS"
    else
        local host="${HOSTNAME:-localhost}"
        advertised="PLAINTEXT://${host}:${port}"
    fi

    cat > "$KAFKA_HOME/config/server.properties" <<EOF
process.roles=broker,controller
node.id=${node_id}
controller.quorum.voters=${node_id}@localhost:${ctrl_port}
listeners=PLAINTEXT://0.0.0.0:${port},CONTROLLER://0.0.0.0:${ctrl_port}
advertised.listeners=${advertised}
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
log.dirs=${LOG_DIRS}
num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
EOF

    if [ ! -f "${LOG_DIRS}/meta.properties" ]; then
        "$KAFKA_HOME/bin/kafka-storage.sh" format \
            -t "$cluster_id" \
            -c "$KAFKA_HOME/config/server.properties" \
            --ignore-formatted
    fi
}

if [ "$1" = "kafka" ]; then
    unset KAFKA_LISTENERS KAFKA_ADVERTISED_LISTENERS
    setup_kraft
    exec "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties" $KAFKA_EXTRA_FLAGS
fi

exec "$@"
