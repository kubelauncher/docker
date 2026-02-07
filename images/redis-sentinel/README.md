# Redis Sentinel

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible Redis Sentinel image for high-availability Redis deployments, based on Ubuntu 24.04. Compiled from source with TLS support. Designed for Kubernetes, built for everyone.

## Supported Tags

- `8.4.0`, `8.4`, `8`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name redis-sentinel \
  -e REDIS_MASTER_HOST=redis \
  -e REDIS_MASTER_PORT=6379 \
  -e REDIS_SENTINEL_QUORUM=2 \
  ghcr.io/kubelauncher/redis-sentinel:8.4.0
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_SENTINEL_PORT` | `26379` | Port Sentinel listens on |
| `REDIS_MASTER_HOST` | `redis` | Hostname of the Redis master |
| `REDIS_MASTER_PORT` | `6379` | Port of the Redis master |
| `REDIS_MASTER_SET` | `mymaster` | Name of the master set |
| `REDIS_SENTINEL_QUORUM` | `2` | Number of Sentinels needed to agree on failover |
| `REDIS_SENTINEL_DOWN_AFTER` | `30000` | Milliseconds before marking master as down |
| `REDIS_SENTINEL_FAILOVER_TIMEOUT` | `180000` | Failover timeout in milliseconds |
| `REDIS_SENTINEL_PARALLEL_SYNCS` | `1` | Number of replicas that can resync simultaneously |
| `REDIS_MASTER_PASSWORD` | _(none)_ | Password to authenticate with the Redis master |
| `REDIS_SENTINEL_PASSWORD` | _(none)_ | Password required to connect to this Sentinel |

## Ports

| Port | Description |
|------|-------------|
| `26379` | Redis Sentinel |

## Data Persistence

Data is stored in `/data/`. Mount a volume to persist Sentinel state:

```bash
docker run -d -v redis-sentinel-data:/data ghcr.io/kubelauncher/redis-sentinel:8.4.0
```

## Configuration

The entrypoint generates a config file at `/data/sentinel.conf` by default. To provide your own config, mount it at `/opt/redis/etc/sentinel.conf`:

```bash
docker run -d -v ./sentinel.conf:/opt/redis/etc/sentinel.conf:ro ghcr.io/kubelauncher/redis-sentinel:8.4.0
```

Read-only ConfigMap mounts are fully supported for Kubernetes deployments.

## Helm Chart

Redis Sentinel is deployed as a mode of the Redis Helm chart:

```bash
helm install my-redis oci://ghcr.io/kubelauncher/charts/redis
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/redis)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/redis-sentinel)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/redis-sentinel)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/redis)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
