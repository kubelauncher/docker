#!/bin/sh
set -e

setup_sentinel_conf() {
    local conf="/opt/redis/etc/sentinel.conf"
    local runtime_conf="/data/sentinel.conf"

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
port ${REDIS_SENTINEL_PORT:-26379}
sentinel resolve-hostnames yes
sentinel announce-hostnames yes

sentinel monitor ${REDIS_MASTER_SET:-mymaster} ${REDIS_MASTER_HOST:-redis} ${REDIS_MASTER_PORT:-6379} ${REDIS_SENTINEL_QUORUM:-2}
sentinel down-after-milliseconds ${REDIS_MASTER_SET:-mymaster} ${REDIS_SENTINEL_DOWN_AFTER:-30000}
sentinel failover-timeout ${REDIS_MASTER_SET:-mymaster} ${REDIS_SENTINEL_FAILOVER_TIMEOUT:-180000}
sentinel parallel-syncs ${REDIS_MASTER_SET:-mymaster} ${REDIS_SENTINEL_PARALLEL_SYNCS:-1}
EOF

    if [ -n "$REDIS_MASTER_PASSWORD" ]; then
        echo "sentinel auth-pass ${REDIS_MASTER_SET:-mymaster} ${REDIS_MASTER_PASSWORD}" >> "$conf"
    fi

    if [ -n "$REDIS_SENTINEL_PASSWORD" ]; then
        echo "requirepass ${REDIS_SENTINEL_PASSWORD}" >> "$conf"
    fi

    echo "$conf"
}

if [ "$1" = "redis-sentinel" ]; then
    conf=$(setup_sentinel_conf)
    shift
    set -- redis-server "$conf" --sentinel "$@"
fi

exec "$@"
