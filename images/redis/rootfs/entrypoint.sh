#!/bin/sh
set -e

setup_redis_conf() {
    local conf="/opt/redis/etc/redis.conf"

    cat > "$conf" <<EOF
bind 0.0.0.0
port ${REDIS_PORT:-6379}
dir /data
appendonly yes
protected-mode no
EOF

    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass ${REDIS_PASSWORD}" >> "$conf"
    fi

    if [ -n "$REDIS_MAXMEMORY" ]; then
        echo "maxmemory ${REDIS_MAXMEMORY}" >> "$conf"
    fi

    if [ -n "$REDIS_MAXMEMORY_POLICY" ]; then
        echo "maxmemory-policy ${REDIS_MAXMEMORY_POLICY}" >> "$conf"
    fi

    if [ -n "$REDIS_DISABLE_COMMANDS" ]; then
        for cmd in $(echo "$REDIS_DISABLE_COMMANDS" | tr ',' ' '); do
            echo "rename-command ${cmd} \"\"" >> "$conf"
        done
    fi

    echo "$conf"
}

if [ "$1" = "redis-server" ]; then
    conf=$(setup_redis_conf)
    shift
    set -- redis-server "$conf" $REDIS_EXTRA_FLAGS "$@"
fi

exec "$@"
