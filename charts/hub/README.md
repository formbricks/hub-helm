# Formbricks Hub Helm Chart

Helm chart for deploying Formbricks Hub, a unified experience data platform with AI enrichment capabilities.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.10+
- PV provisioner support in the underlying infrastructure (if using CloudNativePG)

### Optional Dependencies

- **CloudNativePG Operator** (if using bundled PostgreSQL): [Installation Guide](https://cloudnative-pg.io/documentation/current/installation_upgrade/)
- **External Secrets Operator** (if using external secret management): [Installation Guide](https://external-secrets.io/latest/introduction/getting-started/)
- **Prometheus Operator** (if using ServiceMonitor): [Installation Guide](https://prometheus-operator.dev/docs/prologue/quick-start/)

## Installing the Chart

### Quick Start with External Database

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --set externalDatabase.host=postgres.example.com \
  --set externalDatabase.database=hub \
  --set externalDatabase.username=formbricks \
  --set externalDatabase.password=your-password
```

### With CloudNativePG (Bundled PostgreSQL)

First, install the CloudNativePG operator:

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.0.yaml
```

Then install the chart:

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --set cloudnativepg.enabled=true
```

### With Custom Values File

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --values my-values.yaml
```

## Uninstalling the Chart

```bash
helm uninstall hub
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hub.replicaCount` | Number of Hub replicas | `2` |
| `hub.image.repository` | Hub container image repository | `ghcr.io/formbricks/hub` |
| `hub.image.tag` | Hub container image tag | Chart appVersion |
| `hub.image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hub.config.port` | Application server port | `8080` |
| `hub.config.environment` | Environment (development/production) | `production` |
| `hub.config.logLevel` | Logging level | `info` |
| `hub.config.apiKey.value` | API key (not recommended for production) | `""` |
| `hub.config.apiKey.existingSecret.name` | Existing secret containing API key | `""` |
| `hub.config.databaseUrl` | Override database connection string | `""` |

### OpenAI Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hub.config.openai.enabled` | Enable OpenAI integration | `false` |
| `hub.config.openai.apiKey.value` | OpenAI API key (not recommended for production) | `""` |
| `hub.config.openai.apiKey.existingSecret.name` | Existing secret containing OpenAI API key | `""` |
| `hub.config.openai.apiKey.externalSecret.enabled` | Use External Secrets Operator | `false` |
| `hub.config.openai.enrichmentModel` | Model for text enrichment | `gpt-4o-mini` |
| `hub.config.openai.embeddingModel` | Model for embeddings | `text-embedding-3-small` |

### Database Configuration

#### CloudNativePG (Bundled)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cloudnativepg.enabled` | Enable CloudNativePG cluster | `false` |
| `cloudnativepg.cluster.instances` | Number of PostgreSQL instances | `3` |
| `cloudnativepg.cluster.storage.size` | Storage size for PostgreSQL | `10Gi` |
| `cloudnativepg.cluster.backup.enabled` | Enable automated backups | `false` |

#### External Database

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalDatabase.host` | PostgreSQL host | `""` |
| `externalDatabase.port` | PostgreSQL port | `5432` |
| `externalDatabase.database` | Database name | `hub` |
| `externalDatabase.username` | Database username | `formbricks` |
| `externalDatabase.password` | Database password | `""` |
| `externalDatabase.existingSecret.name` | Existing secret containing password | `""` |
| `externalDatabase.sslMode` | SSL mode | `disable` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts[0].host` | Hostname | `hub.example.com` |
| `ingress.tls` | TLS configuration | `[]` |

### Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hub.autoscaling.enabled` | Enable HPA | `false` |
| `hub.autoscaling.minReplicas` | Minimum replicas | `2` |
| `hub.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `hub.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |

### Resource Limits

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hub.resources.limits.cpu` | CPU limit | `1000m` |
| `hub.resources.limits.memory` | Memory limit | `512Mi` |
| `hub.resources.requests.cpu` | CPU request | `100m` |
| `hub.resources.requests.memory` | Memory request | `128Mi` |

## Examples

### Production Deployment

See [examples/production-values.yaml](../../examples/production-values.yaml) for a complete production configuration with:
- High availability (3 replicas)
- Autoscaling
- CloudNativePG with backups
- Ingress with TLS
- External Secrets integration
- Monitoring

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --values examples/production-values.yaml
```

### External Database

See [examples/external-database.yaml](../../examples/external-database.yaml) for using a managed database service (AWS RDS, Google Cloud SQL, etc.):

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --values examples/external-database.yaml
```

### Minimal Development Setup

See [examples/minimal-values.yaml](../../examples/minimal-values.yaml) for a minimal configuration suitable for development:

```bash
helm install hub oci://ghcr.io/formbricks/charts/hub \
  --values examples/minimal-values.yaml
```

## Upgrading

### To a New Version

```bash
helm upgrade hub oci://ghcr.io/formbricks/charts/hub \
  --version <new-version> \
  --values my-values.yaml
```

### From External Database to CloudNativePG

This requires data migration and is not covered by the chart. Please refer to PostgreSQL migration documentation.

## Security Considerations

### Secrets Management

The chart supports multiple methods for managing secrets:

1. **Direct values** (development only):
   ```yaml
   hub:
     config:
       apiKey:
         value: "my-secret-key"
   ```

2. **Existing Kubernetes Secret**:
   ```yaml
   hub:
     config:
       apiKey:
         existingSecret:
           name: "hub-secrets"
           key: "api-key"
   ```

3. **External Secrets Operator**:
   ```yaml
   hub:
     config:
       openai:
         apiKey:
           externalSecret:
             enabled: true
             secretStore:
               name: "aws-secrets-store"
               kind: "ClusterSecretStore"
             remoteRef:
               key: "prod/hub/openai-key"
   ```

### Pod Security

The chart follows security best practices:
- Runs as non-root user (UID 1000)
- Read-only root filesystem
- Drops all capabilities
- Uses seccomp profile

### Network Policies

Enable network policies for additional security:

```yaml
networkPolicy:
  enabled: true
```

## Monitoring

### Prometheus Integration

Enable ServiceMonitor for Prometheus Operator:

```yaml
serviceMonitor:
  enabled: true
  additionalLabels:
    release: prometheus
```

### CloudNativePG Monitoring

Enable PostgreSQL monitoring:

```yaml
cloudnativepg:
  cluster:
    monitoring:
      enabled: true
      podMonitorEnabled: true
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=hub
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=hub -f
```

### Database Connection Issues

Check database connectivity:

```bash
kubectl exec -it deployment/hub -- sh
# Inside the pod:
wget -O- http://localhost:8080/health
```

### CloudNativePG Issues

Check cluster status:

```bash
kubectl get cluster
kubectl describe cluster <cluster-name>
```

## Support

- Documentation: https://github.com/formbricks/hub
- Issues: https://github.com/formbricks/hub/issues
- Chart Issues: https://github.com/formbricks/hub-helm/issues
