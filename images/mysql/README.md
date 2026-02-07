# MySQL

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible MySQL relational database image based on Ubuntu 24.04. Includes MySQL server and client. Designed for Kubernetes, built for everyone.

## Supported Tags

- `8.0`, `8`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=mysecretpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  ghcr.io/kubelauncher/mysql:8.0
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_PORT_NUMBER` | `3306` | Port MySQL listens on |
| `MYSQL_DATA_DIR` | `/data/mysql/data` | Path to the data directory |
| `MYSQL_ROOT_PASSWORD` | _(none)_ | Password for the `root` user |
| `MYSQL_DATABASE` | _(none)_ | Name of a database to create on first run |
| `MYSQL_USER` | _(none)_ | Name of a user to create on first run |
| `MYSQL_PASSWORD` | _(none)_ | Password for the new user |
| `MYSQL_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `mysqld` |

## Ports

| Port | Description |
|------|-------------|
| `3306` | MySQL server |

## Data Persistence

Data is stored in `/data/mysql/`. Mount a volume to persist data:

```bash
docker run -d -v mysql-data:/data/mysql ghcr.io/kubelauncher/mysql:8.0
```

## Init Scripts

Place `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/` to run them on first initialization:

```bash
docker run -d \
  -v ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  ghcr.io/kubelauncher/mysql:8.0
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-mysql oci://ghcr.io/kubelauncher/charts/mysql
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/mysql)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/mysql)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/mysql)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/mysql)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
