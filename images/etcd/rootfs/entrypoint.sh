#!/bin/bash
set -e

setup_etcd() {
    local data_dir="${ETCD_DATA_DIR:-/data/etcd}"
    mkdir -p "$data_dir"

    ARGS=()

    # Node name
    [ -n "$ETCD_NAME" ] && ARGS+=(--name "$ETCD_NAME")

    # Data directory
    ARGS+=(--data-dir "$data_dir")

    # Client URLs
    [ -n "$ETCD_LISTEN_CLIENT_URLS" ] && ARGS+=(--listen-client-urls "$ETCD_LISTEN_CLIENT_URLS")
    [ -n "$ETCD_ADVERTISE_CLIENT_URLS" ] && ARGS+=(--advertise-client-urls "$ETCD_ADVERTISE_CLIENT_URLS")

    # Peer URLs
    [ -n "$ETCD_LISTEN_PEER_URLS" ] && ARGS+=(--listen-peer-urls "$ETCD_LISTEN_PEER_URLS")
    [ -n "$ETCD_INITIAL_ADVERTISE_PEER_URLS" ] && ARGS+=(--initial-advertise-peer-urls "$ETCD_INITIAL_ADVERTISE_PEER_URLS")

    # Cluster configuration
    [ -n "$ETCD_INITIAL_CLUSTER" ] && ARGS+=(--initial-cluster "$ETCD_INITIAL_CLUSTER")
    [ -n "$ETCD_INITIAL_CLUSTER_STATE" ] && ARGS+=(--initial-cluster-state "$ETCD_INITIAL_CLUSTER_STATE")
    [ -n "$ETCD_INITIAL_CLUSTER_TOKEN" ] && ARGS+=(--initial-cluster-token "$ETCD_INITIAL_CLUSTER_TOKEN")

    # Metrics
    [ -n "$ETCD_LISTEN_METRICS_URLS" ] && ARGS+=(--listen-metrics-urls "$ETCD_LISTEN_METRICS_URLS")

    # Extra flags
    if [ -n "$ETCD_EXTRA_FLAGS" ]; then
        read -ra EXTRA <<< "$ETCD_EXTRA_FLAGS"
        ARGS+=("${EXTRA[@]}")
    fi

    exec etcd "${ARGS[@]}"
}

if [ "$1" = "etcd" ]; then
    setup_etcd
fi

exec "$@"
