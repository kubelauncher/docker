#!/bin/bash
set -e

ZK_HOME="/opt/zookeeper"
ZK_CONFIG="${ZK_HOME}/conf/zoo.cfg"

setup_config() {
    cat > "$ZK_CONFIG" <<EOF
tickTime=${ZOO_TICK_TIME:-2000}
initLimit=${ZOO_INIT_LIMIT:-10}
syncLimit=${ZOO_SYNC_LIMIT:-5}
dataDir=${ZOO_DATA_DIR:-/data/zookeeper/data}
dataLogDir=${ZOO_LOG_DIR:-/data/zookeeper/logs}
clientPort=${ZOO_PORT:-2181}
maxClientCnxns=${ZOO_MAX_CLIENT_CNXNS:-60}
admin.enableServer=true
admin.serverPort=8080
4lw.commands.whitelist=mntr,conf,ruok
EOF

    if [ -n "$ZOO_SERVERS" ]; then
        for server in $(echo "$ZOO_SERVERS" | tr ',' '\n'); do
            echo "$server" >> "$ZK_CONFIG"
        done
    fi

    echo "${ZOO_MY_ID:-1}" > "${ZOO_DATA_DIR:-/data/zookeeper/data}/myid"

    export JVMFLAGS="-Xmx${ZOO_HEAP_SIZE:-512}m -Xms${ZOO_HEAP_SIZE:-512}m"
}

if [ "$1" = "zookeeper" ]; then
    setup_config
    exec "$ZK_HOME/bin/zkServer.sh" start-foreground
fi

exec "$@"
