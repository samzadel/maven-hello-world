# Maven Hello World - CI/CD Project

A Maven-based Java application with automated CI/CD pipeline, Docker containerization, and Kubernetes deployment using Helm.

## Project Structure

```
maven-hello-world/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # CI/CD pipeline configuration
├── helm/
│   └── hello-world-app/        # Helm chart for Kubernetes deployment
│       ├── Chart.yaml          # Chart metadata
│       ├── values.yaml         # Default configuration values
│       └── templates/          # Kubernetes resource templates
├── myapp/
│   ├── pom.xml                 # Maven configuration
│   └── src/
│       ├── main/java/          # Application source code
│       └── test/java/          # Unit tests
├── Dockerfile                  # Multi-stage Docker build configuration
├── .gitignore                  # Git ignore patterns
└── README.md                   # This file
```

## Technology Stack

- **Language**: Java 17
- **Build Tool**: Maven 3.9
- **Containerization**: Docker (Alpine-based images)
- **Orchestration**: Kubernetes with Helm
- **CI/CD**: GitHub Actions
- **Registry**: Docker Hub

## Local Development

### Build and Run with Docker

```bash
# Build Docker image
docker build -t hello-world-app:1.0.0 .

# Run container
docker run hello-world-app:1.0.0
```

## Dockerfile Explanation

Multi-stage Docker build for optimized image size and security:

### Stage 1: Builder
```dockerfile
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
```
- Uses Alpine-based Maven image (lightweight)
- Copies `pom.xml` first for dependency caching
- Downloads dependencies with `mvn dependency:go-offline`
- Copies source code and builds with `mvn clean package`
- Runs tests automatically during build

### Stage 2: Runtime
```dockerfile
FROM eclipse-temurin:17-jre-alpine
```
- Uses JRE-only Alpine image
- Creates non-root user `appuser` for security
- Copies only the JAR file from builder stage
- Runs as non-root user (`USER appuser`)
- Exposes port 8080

**Security**: Application runs as non-root user, following security best practices.

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci-cd.yml`) with 3 jobs:

### Job 1: Build
1. **Increment Version**: Automatically increments patch version (1.0.0 → 1.0.1)
2. **Compile**: Builds Java code with Maven
3. **Test**: Runs unit tests
4. **Package**: Creates JAR artifact
5. **Docker Build**: Creates Docker image
6. **Upload Artifacts**: Saves JAR and Docker image

### Job 2: Docker Deploy
1. **Load Image**: Retrieves Docker image from artifacts
2. **Login**: Authenticates to Docker Hub
3. **Push**: Pushes image to Docker Hub with version tag
4. **Test**: Pulls and runs image to verify

### Job 3: Helm Deploy
1. **Create Cluster**: Spins up local Kubernetes cluster (kind)
2. **Validate**: Lints Helm chart for errors
3. **Deploy**: Installs Helm chart in cluster
4. **Verify**: Checks pod health and readiness
5. **Test**: Views logs to confirm successful deployment
6. **Cleanup**: Removes cluster and resources

**Triggers**: Pipeline runs automatically on push to `main` branch.

## Helm Deployment

Deploy to Kubernetes using Helm:

```bash
# Install the chart
helm install hello-world ./helm/hello-world-app

# Check deployment status
kubectl get pods
kubectl logs -l app.kubernetes.io/name=hello-world-app

# Uninstall
helm uninstall hello-world
```

### Helm Configuration

Edit `helm/hello-world-app/values.yaml`:
```yaml
image:
  repository: your-dockerhub-username/hello-world-app
  tag: "1.0.1"
replicaCount: 1
service:
  type: ClusterIP
  port: 8080
```

## Setup Instructions

### 1. Configure GitHub Secrets

Add these secrets to your GitHub repository:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub access token (not password)

### 2. Update Helm Values

Edit `helm/hello-world-app/values.yaml` and replace `your-dockerhub-username` with your actual Docker Hub username.

### 3. Push to Master

```bash
git add .
git commit -m "feat: initial setup"
git push origin master
```

The CI/CD pipeline will automatically:
- Build and test your application
- Create and push Docker image
- Deploy to Kubernetes
- Verify deployment success

## Environment Variables

Pipeline uses these environment variables:
- `APP_NAME`: Application and image name (hello-world-app)
- `DOCKER_USERNAME`: Docker Hub username (from secrets)
- `DOCKER_PASSWORD`: Docker Hub token (from secrets)

## Version Management

Versions are automatically incremented on each push:
- Format: `MAJOR.MINOR.PATCH` (semantic versioning)
- Increment: Patch version is auto-incremented
- Tagging: Docker images are tagged with the version number

Example: `1.0.0` → `1.0.1` → `1.0.2`

## Monitoring and Logs

```bash
# View pipeline execution
# Go to GitHub → Actions tab

# View application logs (if deployed)
kubectl logs -l app.kubernetes.io/name=hello-world-app

# Check pod status
kubectl get pods
kubectl describe pod <pod-name>
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Pipeline fails at build | Check Maven dependencies in `pom.xml` |
| Docker push fails | Verify Docker Hub credentials in GitHub Secrets |
| Helm deployment fails | Run `helm lint ./helm/hello-world-app` locally |
| Pods not starting | Check image exists: `docker pull username/hello-world-app:version` |
