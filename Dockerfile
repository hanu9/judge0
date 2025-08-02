FROM compilers:latest AS production

# Node.js 22.x LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# TypeScript 5.8.3 (latest stable)
RUN npm install -g typescript@5.8.3 --no-optional

# Install Python
RUN set -xe && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-venv python3-pip && \
    ln -sf /usr/bin/python3.12 /usr/local/bin/python3 && \
    rm -rf /var/lib/apt/lists/*

# Go 1.21.5
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Rust 1.77.2 - Install in /usr/local for all users
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.77.2 && \
    /root/.cargo/bin/rustup default stable && \
    mkdir -p /usr/local/rust && \
    cp -r /root/.rustup/toolchains/stable-* /usr/local/rust/ && \
    ln -sf /usr/local/rust/stable-*/bin/rustc /usr/local/bin/rustc && \
    ln -sf /usr/local/rust/stable-*/bin/cargo /usr/local/bin/cargo && \
    chmod +x /usr/local/bin/rustc /usr/local/bin/cargo

# Java OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# C++ (GCC 9.4.0 - available in Ubuntu 20.04)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      g++ \
      libstdc++-9-dev && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libpq-dev \
      sudo && \
    rm -rf /var/lib/apt/lists/* && \
    echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4 && \
    npm install -g --unsafe-perm aglio@2.3.0

EXPOSE 2358

WORKDIR /api

COPY Gemfile* ./
RUN RAILS_ENV=production bundle

COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

COPY . .

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

USER judge0

ENV JUDGE0_VERSION "1.13.1"
LABEL version=$JUDGE0_VERSION


FROM production AS development

CMD ["sleep", "infinity"]