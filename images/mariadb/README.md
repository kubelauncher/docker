# mariadb

MariaDB relational database on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 3306:3306 \
  -e MARIADB_ROOT_PASSWORD=admin \
  -e MARIADB_DATABASE=mydb \
  -e MARIADB_USER=user \
  -e MARIADB_PASSWORD=pass \
  ghcr.io/kubelauncher/mariadb
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARIADB_PORT_NUMBER` | `3306` | Listen port |
| `MARIADB_ROOT_PASSWORD` | _(empty)_ | Password for root user |
| `MARIADB_DATABASE` | _(empty)_ | Database to create on first run |
| `MARIADB_USER` | _(empty)_ | User to create on first run |
| `MARIADB_PASSWORD` | _(empty)_ | Password for the created user |
| `MARIADB_EXTRA_FLAGS` | _(empty)_ | Extra MariaDB server flags |

## Init scripts

Mount `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: MariaDB Foundation apt repository
- **Data**: `/data/mariadb`
