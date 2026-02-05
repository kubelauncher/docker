# redis-cluster

Redis Cluster node, compiled from source on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 6379:6379 -p 16379:16379 \
  -e REDIS_CLUSTER_ANNOUNCE_IP=192.168.1.100 \
  ghcr.io/kubelauncher/redis-cluster
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PORT` | `6379` | Listen port |
| `REDIS_PASSWORD` | _(empty)_ | Require authentication |
| `REDIS_CLUSTER_ANNOUNCE_IP` | _(empty)_ | Cluster announce IP |
| `REDIS_CLUSTER_ANNOUNCE_PORT` | _(empty)_ | Cluster announce port |
| `REDIS_CLUSTER_ANNOUNCE_BUS_PORT` | _(empty)_ | Cluster bus announce port |
| `REDIS_MAXMEMORY` | _(empty)_ | Memory limit (e.g. `256mb`) |
| `REDIS_MAXMEMORY_POLICY` | _(empty)_ | Eviction policy |
| `REDIS_EXTRA_FLAGS` | _(empty)_ | Additional redis-server flags |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Compiled from source with TLS support
- **Ports**: 6379 (client), 16379 (cluster bus)
