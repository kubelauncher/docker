# ZooKeeper

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible Apache ZooKeeper coordination service image based on Ubuntu 24.04. Built with OpenJDK 17. Designed for Kubernetes, built for everyone.

## Supported Tags

- `3.9.3`, `3.9`, `3`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name zookeeper ghcr.io/kubelauncher/zookeeper:3.9.3
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ZOO_PORT` | `2181` | Client connection port |
| `ZOO_TICK_TIME` | `2000` | Basic time unit in milliseconds |
| `ZOO_INIT_LIMIT` | `10` | Timeout for initial sync (in ticks) |
| `ZOO_SYNC_LIMIT` | `5` | Timeout for sync (in ticks) |
| `ZOO_MAX_CLIENT_CNXNS` | `60` | Maximum client connections per IP |
| `ZOO_DATA_DIR` | `/data/zookeeper/data` | Path to the data directory |
| `ZOO_LOG_DIR` | `/data/zookeeper/logs` | Path to the log directory |
| `ZOO_MY_ID` | `1` | Server ID (auto-extracts ordinal from pod name) |
| `ZOO_SERVERS` | _(none)_ | Comma-separated server list for ensemble |
| `ZOO_HEAP_SIZE` | `512` | JVM heap size in MB |

## Ports

| Port | Description |
|------|-------------|
| `2181` | Client connections |
| `2888` | Follower connections (ensemble) |
| `3888` | Leader election (ensemble) |

## Data Persistence

Data is stored in `/data/zookeeper/`. Mount a volume to persist data:

```bash
docker run -d -v zookeeper-data:/data/zookeeper ghcr.io/kubelauncher/zookeeper:3.9.3
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-zookeeper oci://ghcr.io/kubelauncher/charts/zookeeper
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/zookeeper)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/zookeeper)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/zookeeper)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/zookeeper)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
