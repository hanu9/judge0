# Judge0 Latest Versions Setup

## Overview

This setup focuses on installing the latest stable versions of programming languages for Judge0, using a simple and direct approach.

## Current Language Versions

| Language | Version | Installation Method | Binary Path |
|----------|---------|-------------------|-------------|
| **JavaScript** | 22.x LTS | NodeSource repository | `/usr/bin/node` |
| **TypeScript** | 5.8.3 | npm global install | `/usr/bin/tsc` |
| **Python** | 3.12 | deadsnakes PPA | `/usr/local/bin/python3` |
| **Go** | 1.21.5 | Direct download | `/usr/local/bin/go` |
| **Rust** | 1.77.2 | rustup | `/usr/local/bin/rustc` |
| **C++** | GCC 12.4.0 | apt package | `/usr/bin/g++` |
| **Java** | OpenJDK 17 | apt package | `/usr/bin/java` |
| **Ruby** | 2.7.0 | Source compilation | `/usr/local/ruby-2.7.0/bin/ruby` |

## Installation Details

### JavaScript (Node.js 22.x LTS)
```dockerfile
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs
```

### TypeScript 5.8.3
```dockerfile
RUN npm install -g typescript@5.8.3 --no-optional
```

### Python 3.12
```dockerfile
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y python3.12 python3.12-venv python3-pip && \
    ln -sf /usr/bin/python3.12 /usr/local/bin/python3
```

### Go 1.21.5
```dockerfile
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
```

### Rust 1.77.2
```dockerfile
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.77.2 && \
    ln -sf $HOME/.cargo/bin/rustc /usr/local/bin/rustc
```

### Java OpenJDK 17
```dockerfile
RUN apt-get install -y openjdk-17-jdk
```

### C++ (GCC 12.4.0)
```dockerfile
RUN apt-get install -y --no-install-recommends \
    gcc-12 \
    g++-12 \
    libstdc++-12-dev && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120 --slave /usr/bin/g++ g++ /usr/bin/g++-12
```

## Language Configuration

All languages are configured in `db/languages/active.rb` with IDs starting from 1001:

```ruby
{
  id: 1001,
  name: "Node.js (latest stable)",
  run_cmd: "/usr/bin/node script.js"
},
{
  id: 1003,
  name: "TypeScript (latest stable)",
  compile_cmd: "/usr/bin/tsc %s script.ts",
  run_cmd: "/usr/bin/node script.js"
}
```

## Benefits of This Approach

1. **Simple & Direct** - No complex environment variables or loops
2. **Latest Versions** - Always uses the most recent stable releases
3. **Easy Maintenance** - Clear, readable Dockerfile
4. **Fast Builds** - Minimal complexity, faster compilation
5. **Production Ready** - Stable versions suitable for production use

## How to Update Versions

To update to newer versions, simply modify the specific installation commands in the Dockerfile:

```dockerfile
# Update TypeScript
RUN npm install -g typescript@5.9.0 --no-optional

# Update Go
RUN wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O /tmp/go.tar.gz

# Update Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.78.0
```

## Testing

After building, verify the installations:

```bash
# Build and start
docker-compose build --no-cache
docker-compose up -d

# Check versions
docker-compose exec server node --version
docker-compose exec server tsc --version
docker-compose exec server python3 --version
docker-compose exec server go version
docker-compose exec server rustc --version
docker-compose exec server java --version
docker-compose exec server g++ --version
```

## Troubleshooting

### TypeScript Compilation Issues
- Check TypeScript version: `docker-compose exec server tsc --version`
- Test compilation: `docker-compose exec server bash -c "echo 'console.log(\"test\");' > /tmp/test.ts && tsc /tmp/test.ts"`

### Python Issues
- Verify Python path: `docker-compose exec server which python3`
- Check version: `docker-compose exec server python3 --version`

### Memory/Performance Issues
- Monitor resources: `docker stats`
- Check container limits in `docker-compose.yml`
- Adjust time limits in `judge0.conf` if needed 