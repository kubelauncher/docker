#!/bin/sh
set -e

if [ "$1" = "memcached" ]; then
    shift
    set -- memcached \
        -p "${MEMCACHED_PORT:-11211}" \
        -m "${MEMCACHED_MEMORY:-64}" \
        -c "${MEMCACHED_MAX_CONNECTIONS:-1024}" \
        -u memcached \
        $MEMCACHED_EXTRA_FLAGS \
        "$@"
fi

# Memcached 1.6+ routes verbose logs through its internal watcher system
# instead of stderr. Connect a log watcher to stream runtime logs to stdout.
verbose_enabled=false
for arg in "$@"; do
    case "$arg" in
        -v|-vv|-vvv) verbose_enabled=true ;;
    esac
done

if [ "$verbose_enabled" = "true" ]; then
    "$@" &
    MC_PID=$!

    # Wait for memcached to accept connections
    PORT="${MEMCACHED_PORT:-11211}"
    for i in $(seq 1 30); do
        if printf "version\r\n" | nc -w 1 127.0.0.1 "$PORT" 2>/dev/null | grep -q VERSION; then
            break
        fi
        sleep 0.5
    done

    # Connect a log watcher that streams all events to stdout
    printf "watch mutations fetchers conns evictions\r\n" | nc 127.0.0.1 "$PORT" &
    WATCH_PID=$!

    # Forward signals to memcached
    trap "kill $MC_PID 2>/dev/null; kill $WATCH_PID 2>/dev/null" TERM INT
    wait $MC_PID
    EXIT_CODE=$?
    kill $WATCH_PID 2>/dev/null || true
    exit $EXIT_CODE
fi

exec "$@"
