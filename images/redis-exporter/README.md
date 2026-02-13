# Redis Exporter

Prometheus exporter for Redis metrics.

Upstream: [oliver006/redis_exporter](https://github.com/oliver006/redis_exporter)

## Usage

```bash
docker run -d --name redis-exporter \
  -p 9121:9121 \
  -e REDIS_ADDR=redis://localhost:6379 \
  ghcr.io/kubelauncher/redis-exporter
```

## Ports

| Port | Description |
|------|-------------|
| 9121 | Metrics endpoint |

Built by KubeLauncher — production-grade, open-source, community-first.
