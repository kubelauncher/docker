#!/bin/sh
set -e

REDIS_CONF="/opt/redis/etc/redis.conf"

setup_redis_conf() {
    # If config is mounted read-only (e.g., from Kubernetes ConfigMap), use it
    if [ -f "$REDIS_CONF" ] && ! : >> "$REDIS_CONF" 2>/dev/null; then
        echo "$REDIS_CONF"
        return
    fi

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

    echo "$REDIS_CONF"
}

if [ "$1" = "redis-server" ]; then
    conf=$(setup_redis_conf)
    shift
    set -- redis-server "$conf" $REDIS_EXTRA_FLAGS "$@"
fi

exec "$@"
