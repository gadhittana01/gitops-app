#!/bin/bash

# GitHub Secrets Setup Script for ArgoCD Triggers

set -e

echo "🔧 Setting up GitHub Secrets for ArgoCD Triggers..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo ""
print_status "This script will help you set up GitHub secrets for ArgoCD triggers."
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI (gh) is not installed. You'll need to set secrets manually."
    echo ""
    print_info "Required GitHub Secrets:"
echo "=========================="
echo ""
echo "1. GITOPS_REPO_TOKEN"
echo "   - Value: GitHub Personal Access Token"
echo "   - Purpose: Access to update GitOps repository"
echo ""
echo "2. GITOPS_REPO_OWNER"
echo "   - Value: Your GitHub username"
echo "   - Purpose: GitOps repository owner"
    echo ""
    print_info "To set these secrets manually:"
    echo "1. Go to your GitHub repository"
    echo "2. Settings → Secrets and variables → Actions"
    echo "3. Click 'New repository secret'"
    echo "4. Add each secret with the values above"
    echo ""
    exit 0
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    print_error "You are not authenticated with GitHub CLI."
    print_info "Please run: gh auth login"
    exit 1
fi

print_status "GitHub CLI is available and authenticated."

# Get repository information
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REPO_URL" ]; then
    print_error "Could not determine repository URL. Please run this script from the applications repository."
    exit 1
fi

# Extract repository name
REPO_NAME=$(echo $REPO_URL | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git.*/\1/')
print_status "Repository: $REPO_NAME"

echo ""
print_info "Setting up GitHub secrets for ArgoCD triggers..."
echo ""

# GitOps Repository Update Method
echo "GitOps Repository Update Method"
echo "==============================="
read -p "Enter your GitHub username: " GITHUB_USERNAME
if [ -n "$GITHUB_USERNAME" ]; then
    print_status "Setting GITOPS_REPO_OWNER..."
    gh secret set GITOPS_REPO_OWNER --body "$GITHUB_USERNAME" --repo "$REPO_NAME"
    print_status "✅ GITOPS_REPO_OWNER set successfully!"
fi

echo ""
print_warning "For GITOPS_REPO_TOKEN, you need to create a Personal Access Token:"
echo "1. Go to GitHub.com → Settings → Developer settings → Personal access tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Give it a name like 'GitOps Repository Access'"
echo "4. Select scopes: 'repo' (full control of private repositories)"
echo "5. Copy the generated token"
echo ""

read -p "Enter your GitHub Personal Access Token (or press Enter to skip): " GITHUB_TOKEN
if [ -n "$GITHUB_TOKEN" ]; then
    print_status "Setting GITOPS_REPO_TOKEN..."
    gh secret set GITOPS_REPO_TOKEN --body "$GITHUB_TOKEN" --repo "$REPO_NAME"
    print_status "✅ GITOPS_REPO_TOKEN set successfully!"
fi

echo ""
print_status "🎉 GitHub secrets setup completed!"
echo ""
print_info "Next steps:"
echo "1. Push your changes to trigger the workflow"
echo "2. Check the GitHub Actions tab to see the workflow run"
echo "3. Monitor ArgoCD to see if sync is triggered"
echo ""
print_info "To verify secrets are set:"
echo "gh secret list --repo $REPO_NAME"
echo ""
print_info "To test the setup:"
echo "1. Make a small change to your application code"
echo "2. Commit and push the changes"
echo "3. Check GitHub Actions for the workflow run"
echo "4. Monitor ArgoCD dashboard for sync status"
