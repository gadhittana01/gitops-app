# GitOps Applications Repository

This repository contains the application source code, Dockerfiles, and CI/CD pipeline for the GitOps practical assignment.

## Repository Structure

```
applications/
├── .github/
│   └── workflows/
│       └── build-and-push.yml
├── simple-nginx/
│   ├── Dockerfile
│   └── index.html
├── simple-httpd/
│   ├── Dockerfile
│   └── index.html
└── README.md
```

## Applications

### Simple NGINX
- **Dockerfile**: Custom nginx image with embedded index.html
- **Content**: "Ini tampilan dari NGINX dan nama saya Giri"
- **Port**: 80
- **Image**: `ghcr.io/your-username/gitops-applications/simple-nginx:main`

### Simple HTTPD
- **Dockerfile**: Custom httpd image with embedded index.html
- **Content**: "Ini tampilan dari HTTPD dan nama saya Giri"
- **Port**: 80
- **Image**: `ghcr.io/your-username/gitops-applications/simple-httpd:main`

## CI/CD Pipeline

### GitHub Actions Workflow
The `.github/workflows/build-and-push.yml` workflow:

1. **Triggers**: On push to main/develop branches or pull requests
2. **Builds**: Docker images for both applications
3. **Pushes**: Images to GitHub Container Registry (GHCR)
4. **Tags**: Multiple tags including branch, SHA, and semantic versions
5. **Triggers**: ArgoCD sync after successful builds

### Workflow Features
- **Conditional builds**: Only builds changed applications
- **Multi-platform support**: Uses Docker Buildx
- **Security**: Uses GitHub's built-in container registry
- **Versioning**: Automatic versioning based on Git metadata

## Local Development

### Building Images Locally

```bash
# Build NGINX image
docker build -t simple-nginx:local ./simple-nginx

# Build HTTPD image
docker build -t simple-httpd:local ./simple-httpd
```

### Testing Images

```bash
# Run NGINX container
docker run -p 8080:80 simple-nginx:local

# Run HTTPD container
docker run -p 8081:80 simple-httpd:local
```

## GitOps Integration

This repository works with the separate GitOps repository (`gitops-argocd`) that contains:

1. **ArgoCD Applications**: Define how to deploy these images
2. **Kubernetes Manifests**: Deployment, Service, and other K8s resources
3. **Automated Sync**: ArgoCD automatically syncs when images are updated

## Workflow

1. **Development**: Make changes to application code
2. **Commit & Push**: Push changes to this repository
3. **CI/CD**: GitHub Actions builds and pushes Docker images
4. **ArgoCD Sync**: ArgoCD detects new images and deploys to cluster
5. **Verification**: Applications are automatically updated in Kubernetes

## Configuration

### Environment Variables
- `VERSION`: Application version (from Git SHA)
- `BUILD_TIME`: Build timestamp
- `REGISTRY`: Container registry (GHCR)

### Image Tags
- `main`: Latest from main branch
- `develop`: Latest from develop branch
- `{SHA}`: Specific commit SHA
- `{version}`: Semantic version tags

## Security

- Uses GitHub's built-in container registry
- Automatic vulnerability scanning
- No secrets stored in repository
- Uses GitHub Actions secrets for authentication

## Monitoring

- Health checks in Docker images
- GitHub Actions workflow status
- ArgoCD application health monitoring
- Container registry metrics
