# Memcached

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible Memcached caching system image based on Ubuntu 24.04. Compiled from source for minimal footprint. Designed for Kubernetes, built for everyone.

## Supported Tags

- `1.6.40`, `1.6`, `1`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name memcached ghcr.io/kubelauncher/memcached:1.6.40
```

With custom memory limit:

```bash
docker run -d --name memcached \
  -e MEMCACHED_MEMORY=256 \
  ghcr.io/kubelauncher/memcached:1.6.40
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MEMCACHED_PORT` | `11211` | Port Memcached listens on |
| `MEMCACHED_MEMORY` | `64` | Maximum memory in MB |
| `MEMCACHED_MAX_CONNECTIONS` | `1024` | Maximum simultaneous connections |
| `MEMCACHED_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `memcached` |

## Ports

| Port | Description |
|------|-------------|
| `11211` | Memcached server |

## Data Persistence

Memcached is an in-memory cache and does not persist data to disk. No volume mounts are required.

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-memcached oci://ghcr.io/kubelauncher/charts/memcached
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/memcached)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/memcached)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/memcached)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/memcached)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

Built by KubeLauncher — production-grade, open-source, community-first.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
