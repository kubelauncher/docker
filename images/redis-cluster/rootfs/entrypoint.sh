#!/bin/sh
set -e

setup_cluster_conf() {
    local conf="/opt/redis/etc/redis.conf"
    local runtime_conf="/data/redis.conf"
    local port="${REDIS_PORT:-6379}"

    # If config exists (ConfigMap or pre-existing), copy to runtime and add cluster directives
    if [ -f "$conf" ]; then
        cp "$conf" "$runtime_conf"
        conf="$runtime_conf"
    else
        # Generate base config
        conf="$runtime_conf"
        cat > "$conf" <<EOF
bind 0.0.0.0
port ${port}
protected-mode no
dir /data
appendonly yes
EOF
    fi

    # Always ensure cluster directives are present
    if ! grep -q "^cluster-enabled" "$conf"; then
        echo "cluster-enabled yes" >> "$conf"
    fi
    if ! grep -q "^cluster-config-file" "$conf"; then
        echo "cluster-config-file /data/nodes.conf" >> "$conf"
    fi
    if ! grep -q "^cluster-node-timeout" "$conf"; then
        echo "cluster-node-timeout 5000" >> "$conf"
    fi

    # Add password auth for cluster communication
    if [ -n "$REDIS_PASSWORD" ]; then
        if ! grep -q "^requirepass" "$conf"; then
            echo "requirepass ${REDIS_PASSWORD}" >> "$conf"
        fi
        if ! grep -q "^masterauth" "$conf"; then
            echo "masterauth ${REDIS_PASSWORD}" >> "$conf"
        fi
    fi

    # Hostname-based cluster announcement (Redis 7+)
    # When set, nodes use DNS hostnames instead of IPs in gossip,
    # making the cluster resilient to pod IP changes on restart.
    if [ -n "$REDIS_CLUSTER_ANNOUNCE_HOSTNAME" ]; then
        if ! grep -q "^cluster-announce-hostname" "$conf"; then
            echo "cluster-announce-hostname ${REDIS_CLUSTER_ANNOUNCE_HOSTNAME}" >> "$conf"
        fi
        if ! grep -q "^cluster-preferred-endpoint-type" "$conf"; then
            echo "cluster-preferred-endpoint-type hostname" >> "$conf"
        fi
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_IP" ]; then
        if ! grep -q "^cluster-announce-ip" "$conf"; then
            echo "cluster-announce-ip ${REDIS_CLUSTER_ANNOUNCE_IP}" >> "$conf"
        fi
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_PORT" ]; then
        if ! grep -q "^cluster-announce-port" "$conf"; then
            echo "cluster-announce-port ${REDIS_CLUSTER_ANNOUNCE_PORT}" >> "$conf"
        fi
    fi

    if [ -n "$REDIS_CLUSTER_ANNOUNCE_BUS_PORT" ]; then
        if ! grep -q "^cluster-announce-bus-port" "$conf"; then
            echo "cluster-announce-bus-port ${REDIS_CLUSTER_ANNOUNCE_BUS_PORT}" >> "$conf"
        fi
    fi

    if [ -n "$REDIS_MAXMEMORY" ]; then
        if ! grep -q "^maxmemory " "$conf"; then
            echo "maxmemory ${REDIS_MAXMEMORY}" >> "$conf"
        fi
    fi

    if [ -n "$REDIS_MAXMEMORY_POLICY" ]; then
        if ! grep -q "^maxmemory-policy" "$conf"; then
            echo "maxmemory-policy ${REDIS_MAXMEMORY_POLICY}" >> "$conf"
        fi
    fi

    echo "$conf"
}

if [ "$1" = "redis-server" ]; then
    conf=$(setup_cluster_conf)
    shift
    set -- redis-server "$conf" $REDIS_EXTRA_FLAGS "$@"
fi

exec "$@"
