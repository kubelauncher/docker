# Cassandra

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible Apache Cassandra distributed database image based on Ubuntu 24.04. Built with OpenJDK 17 and Python 3. Designed for Kubernetes, built for everyone.

## Supported Tags

- `5.0.6`, `5.0`, `5`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name cassandra ghcr.io/kubelauncher/cassandra:5.0.6
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CASSANDRA_CLUSTER_NAME` | `Test Cluster` | Name of the Cassandra cluster |
| `CASSANDRA_SEEDS` | _(auto: listen address)_ | Comma-separated list of seed node addresses |
| `CASSANDRA_LISTEN_ADDRESS` | _(auto: container IP)_ | Address to listen for client and inter-node traffic |
| `CASSANDRA_BROADCAST_ADDRESS` | _(auto: listen address)_ | Address broadcast to other nodes |
| `CASSANDRA_RPC_ADDRESS` | `0.0.0.0` | Address to bind for CQL client connections |
| `CASSANDRA_BROADCAST_RPC_ADDRESS` | _(auto: listen address)_ | RPC address broadcast to clients |
| `CASSANDRA_PORT` | `9042` | CQL native transport port |
| `CASSANDRA_STORAGE_PORT` | `7000` | Inter-node communication port |
| `CASSANDRA_DATA_DIR` | `/data/cassandra/data` | Path to the data directory |
| `CASSANDRA_COMMITLOG_DIR` | `/data/cassandra/commitlog` | Path to the commit log directory |
| `CASSANDRA_MAX_HEAP_SIZE` | `512M` | JVM maximum heap size |
| `CASSANDRA_EXTRA_FLAGS` | _(none)_ | Additional flags passed to Cassandra |

## Ports

| Port | Description |
|------|-------------|
| `9042` | CQL native transport (client connections) |
| `7000` | Inter-node cluster communication |
| `7001` | Inter-node communication (TLS) |
| `7199` | JMX monitoring |
| `9160` | Thrift client API (legacy) |

## Data Persistence

Data is stored in `/data/cassandra/`. Mount a volume to persist data:

```bash
docker run -d -v cassandra-data:/data/cassandra ghcr.io/kubelauncher/cassandra:5.0.6
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-cassandra oci://ghcr.io/kubelauncher/charts/cassandra
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/cassandra)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/cassandra)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/cassandra)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/cassandra)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
