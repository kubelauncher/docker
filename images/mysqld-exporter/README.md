# MySQL/MariaDB Exporter

Prometheus exporter for MySQL and MariaDB metrics.

Upstream: [prometheus/mysqld_exporter](https://github.com/prometheus/mysqld_exporter)

## Usage

```bash
docker run -d --name mysqld-exporter \
  -p 9104:9104 \
  -e MYSQLD_EXPORTER_PASSWORD=password \
  ghcr.io/kubelauncher/mysqld-exporter \
  --mysqld.address=127.0.0.1:3306 \
  --mysqld.username=root
```

## Ports

| Port | Description |
|------|-------------|
| 9104 | Metrics endpoint |

Built by KubeLauncher — production-grade, open-source, community-first.
