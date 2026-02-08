# RabbitMQ

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible RabbitMQ message broker image based on Ubuntu 24.04. Includes the management UI and Prometheus metrics plugins enabled by default. Designed for Kubernetes, built for everyone.

## Supported Tags

- `4.2.3`, `4.2`, `4`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name rabbitmq \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=secretpassword \
  ghcr.io/kubelauncher/rabbitmq:4.2.3
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RABBITMQ_DEFAULT_USER` | `guest` | Default username |
| `RABBITMQ_DEFAULT_PASS` | `guest` | Default password |
| `RABBITMQ_DEFAULT_VHOST` | `/` | Default virtual host |
| `RABBITMQ_NODE_TYPE` | `stats` | Node type |
| `RABBITMQ_NODE_NAME` | `rabbit@localhost` | Erlang node name |
| `RABBITMQ_DATA_DIR` | `/data/rabbitmq/data` | Path to the Mnesia data directory |
| `RABBITMQ_LOG_DIR` | `/data/rabbitmq/logs` | Path to the log directory |
| `RABBITMQ_CONF_DIR` | `/data/rabbitmq/conf` | Path to the config directory |
| `RABBITMQ_ERLANG_COOKIE` | _(random)_ | Erlang cookie for clustering |
| `RABBITMQ_PLUGINS` | _(none)_ | Comma-separated list of additional plugins to enable |
| `RABBITMQ_VM_MEMORY_HIGH_WATERMARK` | _(none)_ | Memory watermark (e.g., `0.4`) |
| `RABBITMQ_DISK_FREE_LIMIT` | _(none)_ | Disk free limit (e.g., `1GB`) |

## Ports

| Port | Description |
|------|-------------|
| `5672` | AMQP protocol |
| `15672` | Management UI / HTTP API |
| `4369` | EPMD (Erlang peer discovery) |
| `25672` | Inter-node communication |
| `5671` | AMQP over TLS |
| `15671` | Management UI over TLS |

## Data Persistence

Data is stored in `/data/rabbitmq/`. Mount a volume to persist data:

```bash
docker run -d -v rabbitmq-data:/data/rabbitmq ghcr.io/kubelauncher/rabbitmq:4.2.3
```

## Configuration

The entrypoint generates a config at `/etc/rabbitmq/rabbitmq.conf`. To provide your own config, mount it read-only:

```bash
docker run -d -v ./rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:ro ghcr.io/kubelauncher/rabbitmq:4.2.3
```

Read-only ConfigMap mounts are fully supported for Kubernetes deployments.

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-rabbitmq oci://ghcr.io/kubelauncher/charts/rabbitmq
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/rabbitmq)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/rabbitmq)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/rabbitmq)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/rabbitmq)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
