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
    # Bypass /usr/sbin/rabbitmq-server wrapper which hardcodes stdout redirect
    # to /var/log/rabbitmq/startup_log. Call the real binary directly.
    exec /usr/lib/rabbitmq/bin/rabbitmq-server "$@"
fi

exec "$@"
