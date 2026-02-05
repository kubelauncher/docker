# rabbitmq

RabbitMQ message broker on Ubuntu Linux. Management UI and Prometheus plugin enabled by default.

## Quick start

```bash
docker run -d -p 5672:5672 -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=secret \
  ghcr.io/kubelauncher/rabbitmq
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RABBITMQ_DEFAULT_USER` | `guest` | Default username |
| `RABBITMQ_DEFAULT_PASS` | `guest` | Default password |
| `RABBITMQ_DEFAULT_VHOST` | `/` | Default virtual host |
| `RABBITMQ_ERLANG_COOKIE` | _(random)_ | Erlang distribution cookie |
| `RABBITMQ_VM_MEMORY_HIGH_WATERMARK` | _(empty)_ | Memory watermark (e.g. `0.4`) |
| `RABBITMQ_DISK_FREE_LIMIT` | _(empty)_ | Disk free limit |
| `RABBITMQ_PLUGINS` | _(empty)_ | Comma-separated extra plugins |

Management UI available on port `15672`.

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Generic-unix release from GitHub + Erlang from Cloudsmith packages
- **Data**: `/data/rabbitmq`
