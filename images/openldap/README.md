# OpenLDAP

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Production-ready, broadly compatible OpenLDAP directory service image based on Ubuntu 24.04. Includes slapd and ldap-utils. Automatic initialization with schema loading and base DN creation. Designed for Kubernetes, built for everyone.

## Supported Tags

- `2.6.12`, `2.6`, `2`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run -d --name openldap \
  -e LDAP_ADMIN_PASSWORD=admin \
  -e LDAP_ROOT=dc=example,dc=org \
  ghcr.io/kubelauncher/openldap:2.6.12
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LDAP_PORT` | `389` | Port slapd listens on |
| `LDAP_ADMIN_USERNAME` | `admin` | Admin bind DN username (creates `cn=admin,<LDAP_ROOT>`) |
| `LDAP_ADMIN_PASSWORD` | `admin` | Admin password |
| `LDAP_CONFIG_PASSWORD` | _(same as admin)_ | Config admin password (`cn=admin,cn=config`) |
| `LDAP_ROOT` | `dc=example,dc=org` | LDAP root / base DN |
| `LDAP_ORGANISATION` | `Example Inc.` | Organisation name for the base entry |
| `LDAP_DATA_DIR` | `/data/openldap/data` | Path to the MDB data directory |
| `LDAP_CONFIG_DIR` | `/data/openldap/config` | Path to the slapd config directory |
| `LDAP_EXTRA_ARGS` | _(none)_ | Additional arguments passed to `slapd` |

## Ports

| Port | Description |
|------|-------------|
| `389` | LDAP |
| `636` | LDAPS (TLS) |

## Data Persistence

Data is stored in `/data/openldap/`. Mount a volume to persist data:

```bash
docker run -d -v openldap-data:/data/openldap ghcr.io/kubelauncher/openldap:2.6.12
```

## Init Scripts

Place `.ldif` or `.sh` files in `/docker-entrypoint-initdb.d/` to load them on first initialization:

```bash
docker run -d \
  -v ./users.ldif:/docker-entrypoint-initdb.d/users.ldif:ro \
  ghcr.io/kubelauncher/openldap:2.6.12
```

## Helm Chart

A production-ready Helm chart is available:

```bash
helm install my-openldap oci://ghcr.io/kubelauncher/charts/openldap
```

📦 [View on ArtifactHub](https://artifacthub.io/packages/helm/kubelauncher/openldap)

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/openldap)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/openldap)
- ⎈ [Helm Chart Source](https://github.com/kubelauncher/charts/tree/main/charts/openldap)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/phamitservices/kubernetes-launcher).

## License

Apache-2.0
