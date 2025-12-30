# Hello World App Helm Chart

## Description

Helm chart to deploy the Maven Hello World application on Kubernetes via CI/CD pipeline.

## Automated Deployment

This Helm chart is **automatically deployed** by the GitHub Actions CI/CD pipeline. No manual intervention required.

### Pipeline Workflow

1. **Automatic Configuration**: The pipeline automatically updates `values.yaml` with:
   - Docker Hub username (from `DOCKER_USERNAME` secret)
   - Image version (auto-incremented)

2. **Kubernetes Deployment**: Creates a local Kubernetes cluster (kind) and deploys the application

3. **Health Checks**: Verifies pods are running and healthy

4. **Success Validation**: Confirms deployment before completing

### Trigger

Push to `main` branch triggers automatic deployment:
```bash
git push origin main
```

### Monitor Deployment

View deployment status in GitHub Actions:
- Go to **Actions** tab in your GitHub repository
- Click on the latest workflow run
- Check the `helm-deploy` job logs

## Chart Configuration

The chart uses `values.yaml` for configuration. Key settings:

| Parameter | Description | Default value | Modified by Pipeline |
|-----------|-------------|---------------|---------------------|
| `replicaCount` | Number of replicas | `1` | No |
| `image.repository` | Docker repository | Placeholder | ✅ Yes |
| `image.tag` | Image tag | Placeholder | ✅ Yes |
| `service.type` | K8s service type | `ClusterIP` | No |
| `service.port` | Service port | `8080` | No |
| `resources.limits.memory` | Memory limit | `128Mi` | No |
| `securityContext.runAsUser` | User UID | `1000` | No |

> **Note**: Values marked with ✅ are automatically updated by the pipeline.

## Prerequisites

The following are automatically configured by the CI/CD pipeline:
- ✅ Kubernetes cluster (kind)
- ✅ Helm 3.x installation
- ✅ Docker image availability

You only need to configure GitHub Secrets:
1. Go to your repository **Settings** → **Secrets and variables** → **Actions**
2. Add:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub access token

## Chart Structure

```
helm/hello-world-app/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default values (auto-updated by pipeline)
├── templates/
│   ├── deployment.yaml  # Kubernetes Deployment
│   ├── service.yaml     # Kubernetes Service
│   └── _helpers.tpl     # Template helpers
└── .helmignore          # Files to ignore
```

## Deployment Logs

The pipeline provides detailed logs for each deployment step:
- Chart validation (lint)
- Deployment status
- Pod readiness checks
- Application logs
- Success confirmation

