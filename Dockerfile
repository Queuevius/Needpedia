FROM ruby:2.7.8-bullseye

# Set working directory
WORKDIR /app

# Install OS packages
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    ca-certificates \
    git \
    python2 \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js 14.x via nvm and Yarn (avoids EOL Debian repo issues)
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=12.22.12
RUN mkdir -p "$NVM_DIR" \
  && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && npm install -g yarn \
  && ln -s "$NVM_DIR/versions/node/v$NODE_VERSION/bin/node" /usr/local/bin/node \
  && ln -s "$NVM_DIR/versions/node/v$NODE_VERSION/bin/npm" /usr/local/bin/npm \
  && ln -s "$NVM_DIR/versions/node/v$NODE_VERSION/bin/yarn" /usr/local/bin/yarn

# Install bundler matching project
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Cache gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.4 \
  && bundle install

# Copy application code
COPY . .

# Install JS deps for webpacker
RUN yarn install --frozen-lockfile || yarn install

# Expose port
EXPOSE 3000

# Entrypoint
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["bash", "-lc", "bundle exec rails s -b 0.0.0.0 -p 3000"]


