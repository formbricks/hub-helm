# Formbricks Hub Helm Charts

Official Helm charts for deploying Formbricks Hub on Kubernetes.

## Overview

This repository contains Helm charts for Formbricks Hub, a unified experience data platform with AI enrichment capabilities. The charts are designed to be production-ready with support for high availability, autoscaling, and multiple database deployment options.

## Getting Started

### Prerequisites

- Kubernetes 1.24+
- Helm 3.10+

### Installing the Chart

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub --version 0.1.0
```

For detailed installation instructions and configuration options, see the [chart README](./charts/hub/README.md).

## Available Charts

### Hub

The main Formbricks Hub application chart.

**Features:**
- CloudNativePG integration for PostgreSQL (optional)
- External database support (AWS RDS, Google Cloud SQL, Azure Database, etc.)
- OpenAI integration with multiple secret management options
- Horizontal Pod Autoscaler for dynamic scaling
- Ingress configuration with TLS support
- ServiceMonitor for Prometheus integration
- External Secrets Operator integration
- Production-ready security configurations

**Installation:**
```bash
helm install hub oci://ghcr.io/formbricks/charts/hub
```

**Documentation:** [charts/hub/README.md](./charts/hub/README.md)

## Repository Structure

```
hub-helm/
├── charts/
│   └── hub/                    # Hub application chart
│       ├── Chart.yaml          # Chart metadata
│       ├── values.yaml         # Default configuration
│       ├── README.md           # Chart documentation
│       ├── templates/          # Kubernetes manifests
│       ├── examples/           # Example configurations
│       └── ci/                 # CI test values
├── .github/
│   └── workflows/              # CI/CD workflows
└── README.md                   # This file
```

## Development

### Testing Locally

1. Clone the repository:
```bash
git clone https://github.com/formbricks/hub-helm.git
cd hub-helm
```

2. Lint the chart:
```bash
helm lint charts/hub
```

3. Template the chart:
```bash
helm template test charts/hub --values charts/hub/examples/minimal-values.yaml
```

4. Test installation on a local cluster (kind/minikube):
```bash
# Create kind cluster
kind create cluster --name hub-test

# Install CloudNativePG operator
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.0.yaml

# Install chart
helm install hub charts/hub --values charts/hub/ci/ci-values.yaml
```

### Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/formbricks/hub/blob/main/CONTRIBUTING.md) for details.

#### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally using the steps above
5. Submit a pull request

All pull requests are automatically validated using chart-testing and kind clusters.

## Versioning

This repository follows [Semantic Versioning](https://semver.org/):
- **Major version**: Breaking changes to chart values or behavior
- **Minor version**: New features, backward compatible
- **Patch version**: Bug fixes, no API changes

The chart version is independent from the Hub application version, which is tracked in `Chart.yaml` as `appVersion`.

## Release Process

Releases are automated via GitHub Actions:

1. Create and push a tag:
```bash
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin v0.1.0
```

2. GitHub Actions automatically:
   - Updates Chart.yaml with the release version
   - Packages the Helm chart
   - Publishes to GitHub Container Registry (ghcr.io)
   - Creates a GitHub release with auto-generated changelog
   - Attaches the chart package to the release

## Publishing

Charts are published to GitHub Container Registry and available via OCI:

```bash
# Pull specific version
helm pull oci://ghcr.io/formbricks/charts/hub --version 0.1.0

# Install specific version
helm install hub oci://ghcr.io/formbricks/charts/hub --version 0.1.0
```

## Artifact Hub

The chart is listed on [Artifact Hub](https://artifacthub.io/) for easy discovery.

## Support

### Documentation
- [Hub Application Documentation](https://github.com/formbricks/hub)
- [Chart Documentation](./charts/hub/README.md)
- [Kubernetes Deployment Strategy](https://github.com/formbricks/hub/blob/main/kubernetes-deployment-strategy.md)

### Issues
- Application Issues: [formbricks/hub](https://github.com/formbricks/hub/issues)
- Chart Issues: [formbricks/hub-helm](https://github.com/formbricks/hub-helm/issues)

### Community
- Website: [formbricks.com](https://formbricks.com)
- Email: hola@formbricks.com

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](https://github.com/formbricks/hub/blob/main/LICENSE) file for details.

## Acknowledgments

- Built with [CloudNativePG](https://cloudnative-pg.io/) for PostgreSQL management
- Uses [External Secrets Operator](https://external-secrets.io/) for secret management
- Integrates with [Prometheus Operator](https://prometheus-operator.dev/) for monitoring
