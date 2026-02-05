# openldap

OpenLDAP directory server on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 389:389 \
  -e LDAP_ADMIN_PASSWORD=admin \
  -e LDAP_ROOT=dc=example,dc=org \
  ghcr.io/kubelauncher/openldap
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LDAP_PORT` | `389` | Listen port |
| `LDAP_ADMIN_USERNAME` | `admin` | Admin username |
| `LDAP_ADMIN_PASSWORD` | _(empty)_ | Admin password |
| `LDAP_ROOT` | `dc=example,dc=org` | LDAP root DN |
| `LDAP_ORGANISATION` | `Example Inc.` | Organisation name |
| `LDAP_CONFIG_PASSWORD` | _(empty)_ | Config admin password |
| `LDAP_EXTRA_ARGS` | _(empty)_ | Extra slapd arguments |

## Init scripts

Mount `.ldif` or `.sh` files in `/docker-entrypoint-initdb.d/`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Ubuntu apt packages (`slapd`)
- **Data**: `/data/openldap`
