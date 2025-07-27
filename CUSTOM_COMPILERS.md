# Judge0 Custom Compilers Setup

## Overview

This setup uses a separate custom compilers image (`judge0-compilers:latest`) instead of the official `judge0/compilers:1.4.0` image. This provides more control over language versions and better maintainability.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ubuntu 20.04  │───▶│ Custom Compilers│───▶│   Judge0 App    │
│                 │    │   Image         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ Latest Language │
                       │    Versions     │
                       └─────────────────┘
```

## Custom Compilers Image (`Dockerfile.compilers`)

### Supported Languages

| Language | Version | Binary Path | Notes |
|----------|---------|-------------|-------|
| **Node.js** | 22.x LTS | `/usr/bin/node` | Latest LTS version |
| **TypeScript** | 5.8.3 | `/usr/bin/tsc` | Latest stable |
| **Python** | 3.12 | `/usr/local/bin/python3` | Via deadsnakes PPA |
| **Go** | 1.21.5 | `/usr/local/bin/go` | Direct download |
| **Rust** | 1.77.2 | `/usr/local/bin/rustc` | Via rustup |
| **Java** | OpenJDK 17 | `/usr/bin/java` | Via apt |
| **C++** | GCC 12.4.0 | `/usr/bin/g++` | Latest GCC |
| **Ruby** | 2.7.0 | `/usr/local/ruby-2.7.0/bin/ruby` | Source compilation |

### Key Features

- **Latest Versions**: All languages use the most recent stable releases
- **isolate Sandbox**: Built-in sandboxing tool for secure code execution
- **Optimized Layers**: Efficient Docker layer caching
- **Clean Installation**: Proper cleanup and minimal image size

## Main Application Image (`Dockerfile`)

The main Judge0 application image:
- Uses the custom compilers image as base
- Adds Rails application and dependencies
- Configures the Judge0 runtime environment

## Build Process

### Option 1: Using Build Script (Recommended)
```bash
# Build both images
./build.sh
```

### Option 2: Manual Build
```bash
# Build compilers image
docker build -f Dockerfile.compilers -t judge0-compilers:latest .

# Build main image
docker build -t judge0:latest .
```

### Option 3: Using Docker Compose
```bash
# Build all services
docker-compose build

# Build with no cache
docker-compose build --no-cache
```

## Usage

### Start Services
```bash
docker-compose up -d
```

### Check Language Versions
```bash
# Node.js
docker-compose exec server node --version

# TypeScript
docker-compose exec server tsc --version

# Python
docker-compose exec server python3 --version

# Go
docker-compose exec server go version

# Rust
docker-compose exec server rustc --version

# C++
docker-compose exec server g++ --version

# Java
docker-compose exec server java --version
```

### Test Language Support
```bash
# Test TypeScript
docker-compose exec server bash -c "echo 'console.log(\"Hello TypeScript!\");' > /tmp/test.ts && tsc /tmp/test.ts && node /tmp/test.js"

# Test Python
docker-compose exec server bash -c "echo 'print(\"Hello Python!\")' > /tmp/test.py && python3 /tmp/test.py"

# Test C++
docker-compose exec server bash -c "echo '#include <iostream>\nint main() { std::cout << \"Hello C++!\" << std::endl; return 0; }' > /tmp/test.cpp && g++ /tmp/test.cpp -o /tmp/test && /tmp/test"
```

## Benefits of Custom Compilers

### 1. **Version Control**
- Full control over language versions
- Easy to update to latest releases
- Consistent versions across environments

### 2. **Performance**
- Optimized for Judge0 workloads
- Minimal unnecessary packages
- Efficient layer caching

### 3. **Security**
- Latest security patches
- Controlled dependency versions
- Isolated compilation environment

### 4. **Maintainability**
- Clear separation of concerns
- Easy to modify language versions
- Simple build process

## Updating Language Versions

### 1. Edit `Dockerfile.compilers`
```dockerfile
# Update TypeScript
RUN npm install -g typescript@5.9.0 --no-optional

# Update Go
RUN wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O /tmp/go.tar.gz

# Update Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.78.0
```

### 2. Rebuild Images
```bash
./build.sh
```

### 3. Update Language Configuration
If needed, update `db/languages/active.rb` to reflect new versions.

## Troubleshooting

### Build Issues
```bash
# Clean build
docker system prune -a
./build.sh
```

### Runtime Issues
```bash
# Check logs
docker-compose logs server
docker-compose logs worker

# Check language installations
docker-compose exec server which node
docker-compose exec server which tsc
```

### Performance Issues
```bash
# Monitor resources
docker stats

# Check container limits
docker-compose exec server free -h
```

## File Structure

```
judge0/
├── Dockerfile              # Main Judge0 application
├── Dockerfile.compilers    # Custom compilers image
├── docker-compose.yml      # Service orchestration
├── build.sh               # Build script
├── db/languages/active.rb  # Language configurations
└── CUSTOM_COMPILERS.md    # This documentation
```

This setup provides a clean, maintainable, and efficient way to run Judge0 with the latest language versions! 