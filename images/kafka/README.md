# Kafka

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible Apache Kafka streaming platform image based on Ubuntu 24.04. Runs in KRaft mode (no ZooKeeper required). Built with OpenJDK 17 and Scala 2.13. Designed for Kubernetes, built for everyone.

## Supported Tags

- `3.9.0`, `3.9`, `3`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name kafka ghcr.io/kubelauncher/kafka:3.9.0
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KAFKA_BROKER_ID` | `1` | Broker / node ID (auto-extracts ordinal from pod name) |
| `KAFKA_PORT` | `9092` | Client listener port |
| `KAFKA_CONTROLLER_PORT` | `9093` | Controller listener port |
| `KAFKA_LOG_DIRS` | `/data/kafka/data` | Log data directory |
| `KAFKA_HEAP_OPTS` | `-Xmx512m -Xms512m` | JVM heap settings |
| `KAFKA_LISTENERS` | `PLAINTEXT://:9092,CONTROLLER://:9093` | Listener configuration |
| `KAFKA_ADVERTISED_LISTENERS` | _(auto: hostname)_ | Advertised listeners for client connections |
| `KAFKA_CLUSTER_ID` | _(auto-generated)_ | KRaft cluster ID (persisted to `/data/kafka/.cluster_id`) |
| `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS` | `1@localhost:9093` | Controller quorum voters |
| `KAFKA_CFG_PROCESS_ROLES` | `broker,controller` | Process roles for KRaft mode |
| `KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP` | `CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT` | Listener security protocol map |
| `KAFKA_CFG_CONTROLLER_LISTENER_NAMES` | `CONTROLLER` | Controller listener names |

## Ports

| Port | Description |
|------|-------------|
| `9092` | Kafka client connections |
| `9093` | KRaft controller |

## Data Persistence

Data is stored in `/data/kafka/`. Mount a volume to persist data:

```bash
docker run -d -v kafka-data:/data/kafka ghcr.io/kubelauncher/kafka:3.9.0
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-kafka oci://ghcr.io/kubelauncher/charts/kafka
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/kafka)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/kafka)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/kafka)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/kafka)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
