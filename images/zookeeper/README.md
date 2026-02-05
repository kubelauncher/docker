# zookeeper

Apache ZooKeeper distributed coordination service on Ubuntu Linux.

## Quick start

```bash
docker run -d -p 2181:2181 ghcr.io/kubelauncher/zookeeper
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ZOO_PORT` | `2181` | Client port |
| `ZOO_TICK_TIME` | `2000` | Basic time unit in ms |
| `ZOO_INIT_LIMIT` | `10` | Init sync timeout (ticks) |
| `ZOO_SYNC_LIMIT` | `5` | Sync timeout (ticks) |
| `ZOO_MAX_CLIENT_CNXNS` | `60` | Max client connections |
| `ZOO_MY_ID` | `1` | Server ID |
| `ZOO_SERVERS` | _(empty)_ | Comma-separated server list |
| `ZOO_HEAP_SIZE` | `512` | JVM heap size in MB |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Apache ZooKeeper binary + OpenJDK 17
- **Data**: `/data/zookeeper`
