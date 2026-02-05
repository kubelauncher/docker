# cassandra

Apache Cassandra distributed NoSQL database on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 9042:9042 ghcr.io/kubelauncher/cassandra
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CASSANDRA_CLUSTER_NAME` | `Test Cluster` | Cluster name |
| `CASSANDRA_SEEDS` | `127.0.0.1` | Seed node addresses |
| `CASSANDRA_LISTEN_ADDRESS` | _(auto)_ | Listen address |
| `CASSANDRA_BROADCAST_ADDRESS` | _(auto)_ | Broadcast address |
| `CASSANDRA_RPC_ADDRESS` | `0.0.0.0` | RPC listen address |
| `CASSANDRA_PORT` | `9042` | CQL native port |
| `CASSANDRA_MAX_HEAP_SIZE` | `512M` | JVM max heap |
| `CASSANDRA_HEAP_NEWSIZE` | `128M` | JVM new gen size |
| `CASSANDRA_EXTRA_FLAGS` | _(empty)_ | Extra Cassandra flags |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Apache Cassandra binary + OpenJDK 17
- **Data**: `/data/cassandra`
