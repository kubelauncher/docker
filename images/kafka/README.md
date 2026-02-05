# kafka

Apache Kafka distributed event streaming platform on Ubuntu Linux. Runs in KRaft mode (no ZooKeeper required).

## Quick start

```bash
docker run -d -p 9092:9092 ghcr.io/kubelauncher/kafka
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KAFKA_BROKER_ID` | `1` | Broker node ID |
| `KAFKA_PORT` | `9092` | Client listener port |
| `KAFKA_CONTROLLER_PORT` | `9093` | Controller listener port |
| `KAFKA_LOG_DIRS` | `/data/kafka/data` | Log data directory |
| `KAFKA_HEAP_OPTS` | `-Xmx512m -Xms512m` | JVM heap settings |
| `KAFKA_LISTENERS` | _(auto)_ | Listener configuration |
| `KAFKA_ADVERTISED_LISTENERS` | _(auto)_ | Advertised listeners |
| `KAFKA_CLUSTER_ID` | _(random)_ | KRaft cluster ID |
| `KAFKA_EXTRA_FLAGS` | _(empty)_ | Extra Kafka flags |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Apache Kafka binary + OpenJDK 17
- **Data**: `/data/kafka`
