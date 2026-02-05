# memcached

Memcached distributed memory caching system, compiled from source on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 11211:11211 ghcr.io/kubelauncher/memcached
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MEMCACHED_PORT` | `11211` | Listen port |
| `MEMCACHED_MEMORY` | `64` | Max memory in MB |
| `MEMCACHED_MAX_CONNECTIONS` | `1024` | Max simultaneous connections |
| `MEMCACHED_EXTRA_FLAGS` | _(empty)_ | Additional memcached flags |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Compiled from source
- **Port**: 11211
