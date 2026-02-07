# kubectl

> Packaged with love by [KubeLauncher](https://www.kubelauncher.com) — Bringing love to the Kubernetes community, one image at a time.

Lightweight kubectl CLI utility image based on Ubuntu 24.04. Includes commonly used Kubernetes tooling: `jq`, `yq`, `git`, `envsubst`, and `bash`. SHA256-verified kubectl binary. Designed for Kubernetes, built for everyone.

## Supported Tags

- `1.35.0`, `1.35`, `1`, `latest`

Tags follow semantic versioning. Each push also generates a `sha-<commit>` tag for pinning to exact builds.

## Quick Start

```bash
docker run --rm -v ~/.kube:/home/kubectl/.kube ghcr.io/kubelauncher/kubectl:1.35.0 get nodes
```

Run a specific command:

```bash
docker run --rm \
  -v ~/.kube:/home/kubectl/.kube \
  ghcr.io/kubelauncher/kubectl:1.35.0 get pods -A
```

## Included Tools

| Tool | Description |
|------|-------------|
| `kubectl` | Kubernetes CLI (v1.35.0) |
| `jq` | JSON processor |
| `yq` | YAML processor (v4.52.2) |
| `git` | Version control |
| `envsubst` | Environment variable substitution |
| `bash` | Shell |

## Usage as Init Container

This image is ideal for Kubernetes init containers and Jobs:

```yaml
initContainers:
  - name: wait-for-service
    image: ghcr.io/kubelauncher/kubectl:1.35.0
    command: ["kubectl", "wait", "--for=condition=ready", "pod/my-pod", "--timeout=120s"]
```

## Links

- 📖 [Changelog](https://github.com/kubelauncher/docker/commits/main/images/kubectl)
- 🐳 [Dockerfile](https://github.com/kubelauncher/docker/tree/main/images/kubectl)
- 🌐 [KubeLauncher](https://www.kubelauncher.com)

## About KubeLauncher

KubeLauncher delivers production-ready Kubernetes platforms for startups and scale-ups — in days, not months. These open-source images and Helm charts are our contribution to the community.

Need a production Kubernetes platform? [Let's talk](https://cal.com/kubelauncher).

## License

Apache-2.0
