#!/bin/bash
set -e

setup_rabbitmq() {
    # Ensure HOME is set (may not be in Kubernetes)
    export HOME="${HOME:-/data/rabbitmq}"
    export RABBITMQ_MNESIA_BASE="${RABBITMQ_DATA_DIR:-/data/rabbitmq/data}"
    export RABBITMQ_LOG_BASE="${RABBITMQ_LOG_DIR:-/data/rabbitmq/logs}"

    # Force console logging (rabbitmq-server redirects stdout to files by default)
    export RABBITMQ_LOGS=-

    # Create required directories
    mkdir -p "$RABBITMQ_MNESIA_BASE" "$RABBITMQ_LOG_BASE"

    # ── Handle major-version upgrades (e.g. 3.12 → 4.x) ────────────────
    # RabbitMQ 4.x requires certain feature flags (e.g. stream_filtering)
    # to be enabled BEFORE the upgrade.  When existing Mnesia data comes
    # from a pre-4.x version, the server refuses to boot.
    # Setting RABBITMQ_FORCE_RESET=true wipes the Mnesia database so the
    # node can start fresh.  This loses existing queues and messages.
    if [ -d "$RABBITMQ_MNESIA_BASE" ] && [ "$(ls -A "$RABBITMQ_MNESIA_BASE" 2>/dev/null)" ]; then
        if [ "${RABBITMQ_FORCE_RESET:-false}" = "true" ]; then
            echo "WARNING: RABBITMQ_FORCE_RESET is enabled — clearing Mnesia data at $RABBITMQ_MNESIA_BASE for clean bootstrap..."
            rm -rf "${RABBITMQ_MNESIA_BASE:?}/"*
            echo "Mnesia data cleared."
        fi
    fi

    local conf="/etc/rabbitmq/rabbitmq.conf"
    # Skip config generation if file exists and is read-only (ConfigMap mount)
    if [ -f "$conf" ] && [ ! -w "$conf" ]; then
        echo "Using existing read-only config: $conf"
    else
        cat > "$conf" <<EOF
default_user = ${RABBITMQ_DEFAULT_USER:-guest}
default_pass = ${RABBITMQ_DEFAULT_PASS:-guest}
default_vhost = ${RABBITMQ_DEFAULT_VHOST:-/}
loopback_users = none
listeners.tcp.default = 5672
management.tcp.port = 15672
log.console = true
log.console.level = info
EOF

        if [ -n "$RABBITMQ_VM_MEMORY_HIGH_WATERMARK" ]; then
            echo "vm_memory_high_watermark.relative = ${RABBITMQ_VM_MEMORY_HIGH_WATERMARK}" >> "$conf"
        fi

        if [ -n "$RABBITMQ_DISK_FREE_LIMIT" ]; then
            echo "disk_free_limit.absolute = ${RABBITMQ_DISK_FREE_LIMIT}" >> "$conf"
        fi
    fi

    if [ -n "$RABBITMQ_PLUGINS" ]; then
        for plugin in $(echo "$RABBITMQ_PLUGINS" | tr ',' ' '); do
            rabbitmq-plugins enable --offline "$plugin" 2>/dev/null || true
        done
    fi

    echo "Creating erlang cookie at $HOME/.erlang.cookie..."
    echo "${RABBITMQ_ERLANG_COOKIE:-$(head -c 32 /dev/urandom | base64)}" > "$HOME/.erlang.cookie"
    chmod 600 "$HOME/.erlang.cookie"
    echo "Setup complete."
}

if [ "$1" = "rabbitmq-server" ]; then
    setup_rabbitmq
    echo "Starting RabbitMQ server..."
    shift
    # Locate the rabbitmq-server binary. Path differs between Ubuntu apt install
    # (/usr/lib/rabbitmq/bin) and the official image (/opt/rabbitmq/sbin); also
    # rabbitmq upstream may ship additional variants, so resolve dynamically.
    RMQ_BIN=""
    for candidate in /opt/rabbitmq/sbin/rabbitmq-server /usr/lib/rabbitmq/bin/rabbitmq-server; do
        if [ -x "$candidate" ]; then
            RMQ_BIN="$candidate"
            break
        fi
    done
    if [ -z "$RMQ_BIN" ]; then
        RMQ_BIN="$(command -v rabbitmq-server)"
    fi
    exec "$RMQ_BIN" "$@"
fi

exec "$@"
