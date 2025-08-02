FROM ubuntu:20.04 AS production

ENV JUDGE0_HOMEPAGE="https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE="https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PATH="/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME="/opt/.gem/"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      wget \
      gnupg \
      software-properties-common \
      build-essential \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
      libpq-dev \
      cron \
      sudo \
      git \
      locales \
      perl \
      sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8

# Install Ruby 2.7.0
RUN cd /tmp && \
    wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.0.tar.gz && \
    tar -xzf ruby-2.7.0.tar.gz && \
    cd ruby-2.7.0 && \
    ./configure --disable-install-doc --prefix=/usr/local/ruby-2.7.0 && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/ruby-2.7.0*

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

RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends git libcap-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/judge0/isolate.git /tmp/isolate && \
    cd /tmp/isolate && \
    git checkout ad39cc4d0fbb577fb545910095c9da5ef8fc9a1a && \
    make -j$(nproc) install && \
    rm -rf /tmp/*
    
ENV BOX_ROOT=/var/local/lib/isolate

# Install bundler and aglio
RUN echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4 && \
    npm install -g --unsafe-perm aglio@2.3.0

EXPOSE 2358

WORKDIR /api

COPY Gemfile* ./
RUN RAILS_ENV=production bundle

COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

COPY . .

RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

USER judge0

ENV JUDGE0_VERSION="1.13.1"
LABEL version=$JUDGE0_VERSION

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

FROM production AS development

CMD ["sleep", "infinity"]
