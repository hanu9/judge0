FROM 15071990/compilers:latest AS production

ENV JUDGE0_HOMEPAGE=https://judge0.com
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE=https://github.com/judge0/judge0
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

ENV PATH=/usr/local/ruby-3.4.5/bin:/opt/.gem/bin:$PATH
ENV GEM_HOME=/opt/.gem/

# Update sources.list to use archive.debian.org for EOL releases
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org\/debian-security/g' /etc/apt/sources.list && \
    sed -i '/debian-security\/debian-security/d' /etc/apt/sources.list && \
    sed -i '/bullseye-security/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libpq-dev \
      sudo \
      unzip && \
    rm -rf /var/lib/apt/lists/* && \
    echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.4.22

# Install nlohmann/json
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nlohmann-json3-dev && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 2358

WORKDIR /api

COPY Gemfile* ./
RUN RAILS_ENV=production bundle update --bundler && RAILS_ENV=production bundle

COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

COPY . .

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

USER judge0

ENV JUDGE0_VERSION=1.13.1
LABEL version=$JUDGE0_VERSION


FROM production AS development

CMD ["sleep", "infinity"]