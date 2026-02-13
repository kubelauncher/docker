# MongoDB Exporter

Prometheus exporter for MongoDB metrics.

Upstream: [percona/mongodb_exporter](https://github.com/percona/mongodb_exporter)

## Usage

```bash
docker run -d --name mongodb-exporter \
  -p 9216:9216 \
  -e MONGODB_URI="mongodb://root:password@localhost:27017/admin" \
  ghcr.io/kubelauncher/mongodb-exporter
```

## Ports

| Port | Description |
|------|-------------|
| 9216 | Metrics endpoint |

Built by KubeLauncher — production-grade, open-source, community-first.
