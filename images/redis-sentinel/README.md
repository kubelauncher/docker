# redis-sentinel

Redis Sentinel high-availability monitor, compiled from source on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 26379:26379 \
  -e REDIS_MASTER_HOST=redis-master \
  -e REDIS_SENTINEL_QUORUM=2 \
  ghcr.io/kubelauncher/redis-sentinel
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_SENTINEL_PORT` | `26379` | Sentinel listen port |
| `REDIS_MASTER_HOST` | `redis` | Master hostname |
| `REDIS_MASTER_PORT` | `6379` | Master port |
| `REDIS_MASTER_SET` | `mymaster` | Master set name |
| `REDIS_SENTINEL_QUORUM` | `2` | Quorum for failover |
| `REDIS_SENTINEL_DOWN_AFTER` | `30000` | Down-after-milliseconds |
| `REDIS_SENTINEL_FAILOVER_TIMEOUT` | `180000` | Failover timeout in ms |
| `REDIS_MASTER_PASSWORD` | _(empty)_ | Master authentication password |
| `REDIS_SENTINEL_PASSWORD` | _(empty)_ | Sentinel authentication password |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Compiled from source with TLS support
- **Port**: 26379
