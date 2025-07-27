#!/bin/bash

# Judge0 Custom Compilers Build Script

set -e

echo "🚀 Building Judge0 Custom Compilers Image..."

# Build compilers image first (from empty context - no local files)
echo "📦 Building compilers image..."
docker build -t judge0-compilers:latest - < Dockerfile.compilers

echo "✅ Compilers image built successfully!"

# Build main Judge0 image
echo "🏗️ Building main Judge0 image..."
docker build --target production -t judge0:latest .

echo "✅ Main Judge0 image built successfully!"

echo ""
echo "🎉 All images built successfully!"
echo ""
echo "To start services:"
echo "  docker-compose up -d"
echo ""
echo "To rebuild everything:"
echo "  docker-compose build --no-cache"
echo ""
echo "To check versions:"
echo "  docker-compose exec server ruby --version"
echo "  docker-compose exec server node --version"
echo "  docker-compose exec server tsc --version"
echo "  docker-compose exec server python3 --version"
echo "  docker-compose exec server go version"
echo "  docker-compose exec server rustc --version"
echo "  docker-compose exec server g++ --version"
echo "  docker-compose exec server java --version" 