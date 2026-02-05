# keycloak

Keycloak identity and access management on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  ghcr.io/kubelauncher/keycloak
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KC_HTTP_PORT` | `8080` | HTTP listen port |
| `KC_HTTPS_PORT` | `8443` | HTTPS listen port |
| `KC_HOSTNAME` | _(empty)_ | Public hostname |
| `KC_DB` | _(empty)_ | Database vendor (postgres, mysql, etc.) |
| `KC_DB_URL` | _(empty)_ | JDBC database URL |
| `KC_DB_USERNAME` | _(empty)_ | Database username |
| `KC_DB_PASSWORD` | _(empty)_ | Database password |
| `KEYCLOAK_ADMIN` | _(empty)_ | Admin username |
| `KEYCLOAK_ADMIN_PASSWORD` | _(empty)_ | Admin password |
| `KC_HEALTH_ENABLED` | `true` | Enable health endpoints |
| `KC_METRICS_ENABLED` | `true` | Enable metrics endpoints |
| `KC_EXTRA_ARGS` | _(empty)_ | Extra Keycloak arguments |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Keycloak distribution + OpenJDK 21
- **Data**: `/data/keycloak`
