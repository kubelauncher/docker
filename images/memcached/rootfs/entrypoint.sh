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

exec "$@"
