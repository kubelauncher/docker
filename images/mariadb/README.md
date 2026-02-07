# MariaDB

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible MariaDB relational database image based on Ubuntu 24.04. Includes MariaDB server and client from the official MariaDB Foundation repository. Designed for Kubernetes, built for everyone.

## Supported Tags

- `12.1.2`, `12.1`, `12`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name mariadb \
  -e MARIADB_ROOT_PASSWORD=mysecretpassword \
  -e MARIADB_DATABASE=myapp \
  -e MARIADB_USER=appuser \
  -e MARIADB_PASSWORD=apppass \
  ghcr.io/kubelauncher/mariadb:12.1.2
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARIADB_PORT_NUMBER` | `3306` | Port MariaDB listens on |
| `MARIADB_DATA_DIR` | `/data/mariadb/data` | Path to the data directory |
| `MARIADB_ROOT_PASSWORD` | _(none)_ | Password for the `root` user |
| `MARIADB_DATABASE` | _(none)_ | Name of a database to create on first run |
| `MARIADB_USER` | _(none)_ | Name of a user to create on first run |
| `MARIADB_PASSWORD` | _(none)_ | Password for the new user |
| `MARIADB_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `mariadbd` |

## Ports

| Port | Description |
|------|-------------|
| `3306` | MariaDB server |

## Data Persistence

Data is stored in `/data/mariadb/`. Mount a volume to persist data:

```bash
docker run -d -v mariadb-data:/data/mariadb ghcr.io/kubelauncher/mariadb:12.1.2
```

## Init Scripts

Place `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/` to run them on first initialization:

```bash
docker run -d \
  -v ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  ghcr.io/kubelauncher/mariadb:12.1.2
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-mariadb oci://ghcr.io/kubelauncher/charts/mariadb
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/mariadb)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/mariadb)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/mariadb)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/mariadb)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
