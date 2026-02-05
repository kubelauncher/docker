# mysql

MySQL relational database on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  ghcr.io/kubelauncher/mysql
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_PORT_NUMBER` | `3306` | Listen port |
| `MYSQL_ROOT_PASSWORD` | _(empty)_ | Root password |
| `MYSQL_DATABASE` | _(empty)_ | Database to create on first run |
| `MYSQL_USER` | _(empty)_ | User to create on first run |
| `MYSQL_PASSWORD` | _(empty)_ | Password for the created user |
| `MYSQL_EXTRA_FLAGS` | _(empty)_ | Extra mysqld flags |

## Init scripts

Mount `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Oracle MySQL apt repository
- **Data**: `/data/mysql`
