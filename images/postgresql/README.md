# PostgreSQL

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible PostgreSQL relational database image based on Ubuntu 24.04. Includes PostgreSQL server, client, and contrib modules from the official PGDG repository. Designed for Kubernetes, built for everyone.

## Supported Tags

- `17`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name postgresql \
  -e POSTGRESQL_POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=myapp \
  -e POSTGRESQL_USERNAME=appuser \
  -e POSTGRESQL_PASSWORD=apppass \
  ghcr.io/kubelauncher/postgresql:17
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRESQL_PORT_NUMBER` | `5432` | Port PostgreSQL listens on |
| `POSTGRESQL_DATA_DIR` | `/data/postgresql/data` | Path to the data directory |
| `POSTGRESQL_POSTGRES_PASSWORD` | _(none)_ | Password for the `postgres` superuser |
| `POSTGRESQL_DATABASE` | _(none)_ | Name of a database to create on first run |
| `POSTGRESQL_USERNAME` | _(none)_ | Name of a user to create on first run |
| `POSTGRESQL_PASSWORD` | _(none)_ | Password for the new user |
| `POSTGRESQL_INITDB_ARGS` | _(none)_ | Additional arguments for `initdb` |
| `POSTGRESQL_PG_HBA` | _(none)_ | Custom `pg_hba.conf` content (replaces default) |

## Ports

| Port | Description |
|------|-------------|
| `5432` | PostgreSQL server |

## Data Persistence

Data is stored in `/data/postgresql/`. Mount a volume to persist data:

```bash
docker run -d -v postgresql-data:/data/postgresql ghcr.io/kubelauncher/postgresql:17
```

## Init Scripts

Place `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/` to run them on first initialization. Pre-init scripts can be placed in `/docker-entrypoint-preinitdb.d/` and will run before database initialization.

```bash
docker run -d \
  -v ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  ghcr.io/kubelauncher/postgresql:17
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-postgresql oci://ghcr.io/kubelauncher/charts/postgresql
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/postgresql)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/postgresql)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/postgresql)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/postgresql)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
