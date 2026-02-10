# Redis

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible Redis in-memory data store image based on Ubuntu 24.04. Compiled from source with TLS support. Designed for Kubernetes, built for everyone.

## Supported Tags

- `8.4.0`, `8.4`, `8`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name redis -e REDIS_PASSWORD=secret ghcr.io/kubelauncher/redis:8.4.0
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PORT` | `6379` | Port Redis listens on |
| `REDIS_PASSWORD` | _(none)_ | Set a password (`requirepass`) |
| `REDIS_MAXMEMORY` | _(none)_ | Maximum memory limit (e.g., `256mb`) |
| `REDIS_MAXMEMORY_POLICY` | _(none)_ | Eviction policy (e.g., `allkeys-lru`) |
| `REDIS_DISABLE_COMMANDS` | _(none)_ | Comma-separated list of commands to disable |
| `REDIS_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `redis-server` |

## Ports

| Port | Description |
|------|-------------|
| `6379` | Redis server |

## Data Persistence

Data is stored in `/data/`. Mount a volume to persist data:

```bash
docker run -d -v redis-data:/data ghcr.io/kubelauncher/redis:8.4.0
```

## Configuration

The entrypoint generates a config file at `/data/redis.conf` by default. To provide your own config, mount it at `/opt/redis/etc/redis.conf`:

```bash
docker run -d -v ./redis.conf:/opt/redis/etc/redis.conf:ro ghcr.io/kubelauncher/redis:8.4.0
```

Read-only ConfigMap mounts are fully supported for Kubernetes deployments.

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-redis oci://ghcr.io/kubelauncher/charts/redis
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/redis)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/redis)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/redis)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/redis)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

Built by KubeLauncher — production-grade, open-source, community-first.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
