# Redis Cluster

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible Redis Cluster image for horizontal scaling, based on Ubuntu 24.04. Compiled from source with TLS support. Designed for Kubernetes, built for everyone.

## Supported Tags

- `8.4.0`, `8.4`, `8`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name redis-cluster \
  -e REDIS_PASSWORD=secret \
  -e REDIS_CLUSTER_ANNOUNCE_IP=192.168.1.100 \
  ghcr.io/kubelauncher/redis-cluster:8.4.0
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PORT` | `6379` | Port Redis listens on |
| `REDIS_CLUSTER_BUS_PORT` | `16379` | Cluster bus port for node-to-node communication |
| `REDIS_PASSWORD` | _(none)_ | Set a password (`requirepass` and `masterauth`) |
| `REDIS_CLUSTER_ANNOUNCE_IP` | _(none)_ | IP address announced to other cluster nodes |
| `REDIS_CLUSTER_ANNOUNCE_PORT` | _(none)_ | Port announced to other cluster nodes |
| `REDIS_CLUSTER_ANNOUNCE_BUS_PORT` | _(none)_ | Bus port announced to other cluster nodes |
| `REDIS_MAXMEMORY` | _(none)_ | Maximum memory limit (e.g., `256mb`) |
| `REDIS_MAXMEMORY_POLICY` | _(none)_ | Eviction policy (e.g., `allkeys-lru`) |
| `REDIS_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `redis-server` |

## Ports

| Port | Description |
|------|-------------|
| `6379` | Redis server |
| `16379` | Cluster bus (node-to-node communication) |

## Data Persistence

Data is stored in `/data/`. Mount a volume to persist data:

```bash
docker run -d -v redis-cluster-data:/data ghcr.io/kubelauncher/redis-cluster:8.4.0
```

## Configuration

The entrypoint generates a config file at `/data/redis.conf` with cluster mode enabled by default. To provide your own config, mount it at `/opt/redis/etc/redis.conf`:

```bash
docker run -d -v ./redis.conf:/opt/redis/etc/redis.conf:ro ghcr.io/kubelauncher/redis-cluster:8.4.0
```

Read-only ConfigMap mounts are fully supported for Kubernetes deployments.

## Helm Chart

Redis Cluster is deployed as a mode of the Redis Helm chart:

```bash
helm install my-redis oci://ghcr.io/kubelauncher/charts/redis
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/redis)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/redis-cluster)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/redis-cluster)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/redis)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
