#!/bin/sh
set -e

setup_cluster_conf() {
    local conf="/opt/redis/etc/redis.conf"
    local runtime_conf="/data/redis.conf"
    local port="${REDIS_PORT:-6379}"

    # If config exists and is read-only (ConfigMap mount), use it directly
    if [ -f "$conf" ] && [ ! -w "$conf" ]; then
        echo "$conf"
        return
    fi

    # If config exists and is writable, use it
    if [ -f "$conf" ] && [ -w "$conf" ]; then
        echo "$conf"
        return
    fi

    # Generate config in /data (always writable)
    conf="$runtime_conf"

    cat > "$conf" <<EOF
bind 0.0.0.0
port ${port}
protected-mode no
dir /data
cluster-enabled yes
cluster-config-file /data/nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF

    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass ${REDIS_PASSWORD}" >> "$conf"
        echo "masterauth ${REDIS_PASSWORD}" >> "$conf"
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_IP" ]; then
        echo "cluster-announce-ip ${REDIS_CLUSTER_ANNOUNCE_IP}" >> "$conf"
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_PORT" ]; then
        echo "cluster-announce-port ${REDIS_CLUSTER_ANNOUNCE_PORT}" >> "$conf"
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_BUS_PORT" ]; then
        echo "cluster-announce-bus-port ${REDIS_CLUSTER_ANNOUNCE_BUS_PORT}" >> "$conf"
    fi

    if [ -n "$REDIS_MAXMEMORY" ]; then
        echo "maxmemory ${REDIS_MAXMEMORY}" >> "$conf"
    fi

    if [ -n "$REDIS_MAXMEMORY_POLICY" ]; then
        echo "maxmemory-policy ${REDIS_MAXMEMORY_POLICY}" >> "$conf"
    fi

    echo "$conf"
}

if [ "$1" = "redis-server" ]; then
    conf=$(setup_cluster_conf)
    shift
    set -- redis-server "$conf" $REDIS_EXTRA_FLAGS "$@"
fi

exec "$@"
