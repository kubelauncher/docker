#!/bin/sh
set -e

REDIS_CONF="/opt/redis/etc/redis.conf"
REDIS_CONF_RUNTIME="/data/redis.conf"

needs_replication_config() {
    [ "$REDIS_REPLICATION_MODE" = "replica" ] && [ -n "$REDIS_MASTER_HOST" ]
}

append_replication_config() {
    local conf="$1"
    if needs_replication_config; then
        echo "replicaof ${REDIS_MASTER_HOST} ${REDIS_MASTER_PORT:-6379}" >> "$conf"
        if [ -n "$REDIS_MASTER_PASSWORD" ]; then
            echo "masterauth ${REDIS_MASTER_PASSWORD}" >> "$conf"
        fi
    fi
}

setup_redis_conf() {
    # If config exists (e.g., Kubernetes ConfigMap)
    if [ -f "$REDIS_CONF" ]; then
        # If read-only OR we need to add replication config, copy to writable location
        if [ ! -w "$REDIS_CONF" ] || needs_replication_config; then
            echo "Using existing read-only config: $REDIS_CONF"
            cp "$REDIS_CONF" "$REDIS_CONF_RUNTIME"
            append_replication_config "$REDIS_CONF_RUNTIME"
            echo "$REDIS_CONF_RUNTIME"
            return
        fi
        echo "$REDIS_CONF"
        return
    fi

    # Generate config in /data (always writable)
    REDIS_CONF="$REDIS_CONF_RUNTIME"

    cat > "$REDIS_CONF" <<EOF
bind 0.0.0.0
port ${REDIS_PORT:-6379}
dir /data
appendonly yes
protected-mode no
EOF

    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass ${REDIS_PASSWORD}" >> "$REDIS_CONF"
    fi

    if [ -n "$REDIS_MAXMEMORY" ]; then
        echo "maxmemory ${REDIS_MAXMEMORY}" >> "$REDIS_CONF"
    fi

    if [ -n "$REDIS_MAXMEMORY_POLICY" ]; then
        echo "maxmemory-policy ${REDIS_MAXMEMORY_POLICY}" >> "$REDIS_CONF"
    fi

    if [ -n "$REDIS_DISABLE_COMMANDS" ]; then
        for cmd in $(echo "$REDIS_DISABLE_COMMANDS" | tr ',' ' '); do
            echo "rename-command ${cmd} \"\"" >> "$REDIS_CONF"
        done
    fi

    append_replication_config "$REDIS_CONF"

    echo "$REDIS_CONF"
}

if [ "$1" = "redis-server" ]; then
    conf=$(setup_redis_conf)
    shift
    set -- redis-server "$conf" $REDIS_EXTRA_FLAGS "$@"
fi

exec "$@"
