# MongoDB

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible MongoDB document database image based on Ubuntu 24.04. Installed from the official MongoDB repository. Designed for Kubernetes, built for everyone.

## Supported Tags

- `8.2`, `8`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name mongodb \
  -e MONGODB_ROOT_PASSWORD=mysecretpassword \
  -e MONGODB_DATABASE=myapp \
  -e MONGODB_USERNAME=appuser \
  -e MONGODB_PASSWORD=apppass \
  ghcr.io/kubelauncher/mongodb:8.2
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_PORT` | `27017` | Port MongoDB listens on |
| `MONGODB_DATA_DIR` | `/data/mongodb/data` | Path to the data directory |
| `MONGODB_LOG_DIR` | `/data/mongodb/logs` | Path to the log directory |
| `MONGODB_ROOT_USERNAME` | `root` | Username for the root admin user |
| `MONGODB_ROOT_PASSWORD` | _(none)_ | Password for the root admin user (enables auth) |
| `MONGODB_DATABASE` | _(none)_ | Name of a database to create on first run |
| `MONGODB_USERNAME` | _(none)_ | Name of a user to create with `readWrite` access |
| `MONGODB_PASSWORD` | _(none)_ | Password for the new user |
| `MONGODB_EXTRA_FLAGS` | _(none)_ | Additional flags passed to `mongod` |

## Ports

| Port | Description |
|------|-------------|
| `27017` | MongoDB server |

## Data Persistence

Data is stored in `/data/mongodb/`. Mount a volume to persist data:

```bash
docker run -d -v mongodb-data:/data/mongodb ghcr.io/kubelauncher/mongodb:8.2
```

## Init Scripts

Place `.sh` or `.js` files in `/docker-entrypoint-initdb.d/` to run them on first initialization:

```bash
docker run -d \
  -v ./init.js:/docker-entrypoint-initdb.d/init.js:ro \
  ghcr.io/kubelauncher/mongodb:8.2
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-mongodb oci://ghcr.io/kubelauncher/charts/mongodb
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/mongodb)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/mongodb)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/mongodb)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/mongodb)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
