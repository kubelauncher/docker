# postgresql

PostgreSQL relational database on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 5432:5432 \
  -e POSTGRESQL_POSTGRES_PASSWORD=admin \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=user \
  -e POSTGRESQL_PASSWORD=pass \
  ghcr.io/kubelauncher/postgresql
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRESQL_PORT_NUMBER` | `5432` | Listen port |
| `POSTGRESQL_POSTGRES_PASSWORD` | _(empty)_ | Password for `postgres` superuser |
| `POSTGRESQL_DATABASE` | _(empty)_ | Database to create on first run |
| `POSTGRESQL_USERNAME` | _(empty)_ | User to create on first run |
| `POSTGRESQL_PASSWORD` | _(empty)_ | Password for the created user |
| `POSTGRESQL_INITDB_ARGS` | _(empty)_ | Extra args for `initdb` |

## Init scripts

Mount `.sh`, `.sql`, or `.sql.gz` files in `/docker-entrypoint-initdb.d/`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: PGDG packages (`postgresql-17`)
- **Data**: `/data/postgresql`
