# redis

Redis in-memory data store, compiled from source on Alpine Linux.

## Quick start

```bash
docker run -d -p 6379:6379 -e REDIS_PASSWORD=secret ghcr.io/kubelauncher/redis
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PORT` | `6379` | Listen port |
| `REDIS_PASSWORD` | _(empty)_ | Require authentication |
| `REDIS_MAXMEMORY` | _(empty)_ | Memory limit (e.g. `256mb`) |
| `REDIS_MAXMEMORY_POLICY` | _(empty)_ | Eviction policy |
| `REDIS_DISABLE_COMMANDS` | _(empty)_ | Comma-separated commands to disable |
| `REDIS_EXTRA_FLAGS` | _(empty)_ | Additional redis-server flags |

## Build details

- **Base**: Alpine 3.23
- **Build**: Compiled from source with TLS support
- **Data**: `/data`
