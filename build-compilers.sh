#!/bin/bash

# Build Judge0 Compilers Image Only
# This builds the compilers image from an empty context (no local files)

set -e

echo "🚀 Building Judge0 Compilers Image..."

# Build compilers image from empty context (multi-arch)
echo "📦 Building compilers image..."
sudo docker buildx build --platform linux/amd64 -t judge0-compilers:latest - < Dockerfile.compilers

echo "✅ Compilers image built successfully!"
echo ""
echo "Image: judge0-compilers:latest"
echo ""
echo "To build the main application:"
echo "  docker build -t judge0:latest ."
echo ""
echo "To start services:"
echo "  docker-compose up -d" 