# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

Report security issues via [GitHub Issues](../../issues) with the label `security`.

For critical vulnerabilities, use GitHub's private vulnerability reporting feature.

## Security Measures

- Images scanned with [Grype](https://github.com/anchore/grype) on every build
- Artifacts signed with [Cosign](https://docs.sigstore.dev/cosign/overview/)
- Non-root containers (UID 1001)
- Automated dependency updates via Renovate
