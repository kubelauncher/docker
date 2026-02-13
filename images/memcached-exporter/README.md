# Memcached Exporter

Prometheus exporter for Memcached metrics.

Upstream: [prometheus/memcached_exporter](https://github.com/prometheus/memcached_exporter)

## Usage

```bash
docker run -d --name memcached-exporter \
  -p 9150:9150 \
  ghcr.io/kubelauncher/memcached-exporter \
  --memcached.address=localhost:11211
```

## Ports

| Port | Description |
|------|-------------|
| 9150 | Metrics endpoint |

Built by KubeLauncher — production-grade, open-source, community-first.
