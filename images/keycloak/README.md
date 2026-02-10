# Keycloak

> Built by [KubeLauncher](https://www.kubelauncher.com) — production-grade, open-source, community-first.

Production-ready, broadly compatible Keycloak identity and access management image based on Ubuntu 24.04. Built with OpenJDK 21. Health and metrics endpoints enabled by default. Designed for Kubernetes, built for everyone.

## Supported Tags

- `26.5.2`, `26.5`, `26`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name keycloak \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  ghcr.io/kubelauncher/keycloak:26.5.2
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KC_HTTP_PORT` | `8080` | HTTP listen port |
| `KC_HTTPS_PORT` | `8443` | HTTPS listen port |
| `KC_DB` | `dev-file` | Database vendor (`dev-file`, `postgres`, `mysql`, `mariadb`) |
| `KC_DB_URL` | _(none)_ | JDBC database URL |
| `KC_DB_USERNAME` | _(none)_ | Database username |
| `KC_DB_PASSWORD` | _(none)_ | Database password |
| `KC_HOSTNAME` | _(none)_ | Public hostname for Keycloak |
| `KEYCLOAK_ADMIN` | _(none)_ | Initial admin username |
| `KEYCLOAK_ADMIN_PASSWORD` | _(none)_ | Initial admin password |
| `KC_HEALTH_ENABLED` | `true` | Enable health check endpoints (port 9000) |
| `KC_METRICS_ENABLED` | `true` | Enable Prometheus metrics endpoints |
| `KC_EXTRA_ARGS` | _(none)_ | Additional arguments passed to `kc.sh` |

## Ports

| Port | Description |
|------|-------------|
| `8080` | HTTP |
| `8443` | HTTPS |
| `9000` | Health and metrics endpoints |

## Data Persistence

Data is stored in `/data/keycloak/`. Mount a volume to persist data:

```bash
docker run -d -v keycloak-data:/data/keycloak ghcr.io/kubelauncher/keycloak:26.5.2
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-keycloak oci://ghcr.io/kubelauncher/charts/keycloak
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/keycloak)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/keycloak)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/keycloak)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/keycloak)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

Built by KubeLauncher — production-grade, open-source, community-first.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
