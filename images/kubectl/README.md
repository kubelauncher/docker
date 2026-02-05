# kubectl

Kubernetes CLI utility container on Ubuntu Linux. Includes `jq`, `yq`, `git`, and `envsubst`.

## Quick start

```bash
docker run --rm -v ~/.kube:/home/kubectl/.kube ghcr.io/kubelauncher/kubectl get nodes
```

## Included tools

| Tool | Description |
|------|-------------|
| `kubectl` | Kubernetes CLI |
| `jq` | JSON processor |
| `yq` | YAML processor |
| `git` | Version control |
| `envsubst` | Environment variable substitution |
| `bash` | Shell |

## Build details

- **Base**: Ubuntu 24.04
- **Build**: Official kubectl binary + yq from GitHub releases (SHA256 verified)
