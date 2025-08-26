# ArgoCD Trigger Setup Guide

This guide explains how to set up real ArgoCD triggers instead of the fake placeholder in the GitHub Actions workflow.

## Why the Previous Trigger Was Fake

The original trigger was just a placeholder that printed messages but didn't actually trigger ArgoCD. Here are the real methods to trigger ArgoCD:

## Method 1: ArgoCD Webhook (Recommended)

### Step 1: Enable ArgoCD Webhook
```bash
# Enable webhook in ArgoCD
kubectl patch deployment argocd-server -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","env":[{"name":"ARGOCD_WEBHOOK_ENABLED","value":"true"}]}]}}}}'
```

### Step 2: Get Webhook URL
```bash
# Get the webhook URL
kubectl get route argocd-server -n argocd -o jsonpath='{.spec.host}'
# or for LoadBalancer
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### Step 3: Configure GitHub Secrets
Add these secrets to your GitHub repository:
- `ARGOCD_WEBHOOK_URL`: `https://your-argocd-domain/webhook`

### Step 4: Update Applications for Webhook
Add webhook configuration to your ArgoCD applications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simple-nginx
  namespace: argocd
  annotations:
    argocd.argoproj.io/webhook-enabled: "true"
spec:
  # ... existing spec
```

## Method 2: ArgoCD API

### Step 1: Get ArgoCD API Token
```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login to ArgoCD
argocd login your-argocd-domain --username admin --password <password>

# Create API token
argocd account generate-token --account github-actions
```

### Step 2: Configure GitHub Secrets
Add these secrets to your GitHub repository:
- `ARGOCD_API_URL`: `https://your-argocd-domain`
- `ARGOCD_API_TOKEN`: `<token-from-step-1>`

## Method 3: GitOps Repository Update (Most Common)

### Step 1: Create Personal Access Token
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create a token with `repo` permissions
3. Copy the token

### Step 2: Configure GitHub Secrets
Add these secrets to your GitHub repository:
- `GITOPS_REPO_TOKEN`: `<your-personal-access-token>`
- `GITOPS_REPO_OWNER`: `your-github-username`

### Step 3: How It Works
This method:
1. Clones the GitOps repository
2. Updates image tags in deployment files
3. Commits and pushes changes
4. ArgoCD detects changes and syncs automatically

## Method 4: ArgoCD Image Updater (Advanced)

### Step 1: Install ArgoCD Image Updater
```bash
# Add the Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD Image Updater
helm install argocd-image-updater argo/argocd-image-updater \
  --namespace argocd \
  --set config.registries[0].name=ghcr.io \
  --set config.registries[0].api_url=https://ghcr.io \
  --set config.registries[0].credentials=secret:argocd/ghcr-secret#token
```

### Step 2: Configure Image Updater
Add annotations to your applications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simple-nginx
  namespace: argocd
  annotations:
    argocd-image-updater.argoproj.io/image-list: nginx=ghcr.io/your-username/gitops-applications/simple-nginx
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: main
spec:
  # ... existing spec
```

## Method 5: ArgoCD Notifications (Enterprise)

### Step 1: Install ArgoCD Notifications
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml
```

### Step 2: Configure Notifications
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.webhook.github: |
    url: https://api.github.com/repos/your-username/gitops-argocd/dispatches
    headers:
      - name: Authorization
        value: token $github-token
      - name: Accept
        value: application/vnd.github.v3+json
    body: |
      {
        "event_type": "argocd-sync",
        "client_payload": {
          "repository": "{{.app.metadata.name}}",
          "revision": "{{.app.status.operationState.operation.sync.revision}}"
        }
      }
```

## Current Implementation

The updated workflow now includes **all three methods**:

1. **Webhook**: Direct ArgoCD webhook call
2. **API**: ArgoCD REST API calls
3. **GitOps Update**: Updates the GitOps repository

### Required GitHub Secrets

For the current implementation to work, you need to set these secrets in your GitHub repository:

```bash
# Method 1: Webhook
ARGOCD_WEBHOOK_URL=https://your-argocd-domain/webhook

# Method 2: API
ARGOCD_API_URL=https://your-argocd-domain
ARGOCD_API_TOKEN=your-api-token

# Method 3: GitOps Repository Update
GITOPS_REPO_TOKEN=your-github-personal-access-token
GITOPS_REPO_OWNER=your-github-username
```

## Testing the Triggers

### Test Webhook
```bash
curl -X POST "https://your-argocd-domain/webhook" \
  -H "Content-Type: application/json" \
  -d '{"repository": "your-username/gitops-applications", "revision": "main"}'
```

### Test API
```bash
curl -X POST "https://your-argocd-domain/api/v1/applications/simple-nginx/sync" \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"revision": "main"}'
```

### Test GitOps Update
```bash
# This will be automatically tested when you push to the applications repository
```

## Troubleshooting

### Webhook Issues
- Check if webhook is enabled in ArgoCD
- Verify webhook URL is accessible
- Check ArgoCD server logs

### API Issues
- Verify API token has correct permissions
- Check ArgoCD API server logs
- Ensure API is accessible

### GitOps Update Issues
- Verify personal access token has repo permissions
- Check if GitOps repository is accessible
- Review GitHub Actions logs

## Best Practices

1. **Use Method 3 (GitOps Update)** for most setups - it's the most reliable
2. **Combine methods** for redundancy
3. **Use webhooks** for real-time triggers
4. **Use API** for programmatic control
5. **Monitor logs** for troubleshooting

## Security Considerations

- Use least-privilege tokens
- Rotate tokens regularly
- Use HTTPS for all connections
- Monitor access logs
- Use RBAC for ArgoCD access
