# mongodb

MongoDB document database on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 27017:27017 \
  -e MONGODB_ROOT_PASSWORD=admin \
  -e MONGODB_DATABASE=mydb \
  -e MONGODB_USERNAME=user \
  -e MONGODB_PASSWORD=pass \
  ghcr.io/kubelauncher/mongodb
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_PORT` | `27017` | Listen port |
| `MONGODB_ROOT_USERNAME` | `root` | Root admin username |
| `MONGODB_ROOT_PASSWORD` | _(empty)_ | Root admin password |
| `MONGODB_DATABASE` | _(empty)_ | Database to create on first run |
| `MONGODB_USERNAME` | _(empty)_ | User to create on first run |
| `MONGODB_PASSWORD` | _(empty)_ | Password for the created user |
| `MONGODB_EXTRA_FLAGS` | _(empty)_ | Extra mongod flags |

## Init scripts

Mount `.sh` or `.js` files in `/docker-entrypoint-initdb.d/`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: MongoDB Inc apt repository
- **Data**: `/data/mongodb`
