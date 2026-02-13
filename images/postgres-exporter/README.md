# PostgreSQL Exporter

Prometheus exporter for PostgreSQL metrics.

Upstream: [prometheus-community/postgres_exporter](https://github.com/prometheus-community/postgres_exporter)

## Usage

```bash
docker run -d --name postgres-exporter \
  -p 9187:9187 \
  -e DATA_SOURCE_URI="localhost:5432/postgres?sslmode=disable" \
  -e DATA_SOURCE_USER=postgres \
  -e DATA_SOURCE_PASS=password \
  ghcr.io/kubelauncher/postgres-exporter
```

## Ports

| Port | Description |
|------|-------------|
| 9187 | Metrics endpoint |

Built by KubeLauncher — production-grade, open-source, community-first.
