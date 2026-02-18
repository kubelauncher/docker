#!/bin/bash
set -e

setup_etcd() {
    local data_dir="${ETCD_DATA_DIR:-/data/etcd}"
    mkdir -p "$data_dir"

    # etcd natively reads ETCD_* environment variables.
    # No CLI flags needed — avoids "conflicting environment variable" errors.
    # Extra flags (non-ETCD_* prefixed) can be passed via ETCD_EXTRA_FLAGS.

    ARGS=()
    if [ -n "$ETCD_EXTRA_FLAGS" ]; then
        read -ra ARGS <<< "$ETCD_EXTRA_FLAGS"
    fi

    # Unset ETCD_EXTRA_FLAGS so etcd doesn't see it as a config var
    unset ETCD_EXTRA_FLAGS

    exec etcd "${ARGS[@]}"
}

if [ "$1" = "etcd" ]; then
    setup_etcd
fi

exec "$@"
