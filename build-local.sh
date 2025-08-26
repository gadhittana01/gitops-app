#!/bin/bash

# Local Build Script for Applications

set -e

echo "🔨 Building Applications Locally..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

print_status "✅ Docker is available"

# Build NGINX image
print_status "Building Simple NGINX image..."
docker build -t simple-nginx:local ./simple-nginx

# Build HTTPD image
print_status "Building Simple HTTPD image..."
docker build -t simple-httpd:local ./simple-httpd

print_status "✅ All images built successfully!"

echo ""
print_status "🎉 Local build completed!"
echo ""
echo "📋 Built Images:"
echo "   - simple-nginx:local"
echo "   - simple-httpd:local"
echo ""
echo "🧪 To test images:"
echo "   # Run NGINX"
echo "   docker run -p 8080:80 simple-nginx:local"
echo "   # Access at: http://localhost:8080"
echo ""
echo "   # Run HTTPD"
echo "   docker run -p 8081:80 simple-httpd:local"
echo "   # Access at: http://localhost:8081"
echo ""
echo "📦 To push to registry:"
echo "   # Tag for your registry"
echo "   docker tag simple-nginx:local your-registry/simple-nginx:latest"
echo "   docker tag simple-httpd:local your-registry/simple-httpd:latest"
echo ""
echo "   # Push to registry"
echo "   docker push your-registry/simple-nginx:latest"
echo "   docker push your-registry/simple-httpd:latest"
