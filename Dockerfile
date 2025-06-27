# Base Image
FROM serversideup/php:8.3-fpm-nginx AS base
USER root

# Install system dependencies and Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs unzip git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Build Stage
FROM base AS build
ARG DEV_MODE=false
USER www-data

# Copy package files first (better layer caching)
COPY --chown=www-data:www-data package*.json ./
RUN npm install --production

COPY --chown=www-data:www-data composer.* ./
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy full source code
COPY --chown=www-data:www-data ./ /var/www/html

# Final composer install depending on mode
RUN if [ "$DEV_MODE" = "true" ]; then \
    composer install --no-interaction --prefer-dist; \
else \
    composer install --no-dev --optimize-autoloader; \
fi

# Dev Stage
FROM build AS dev
USER root

# ✅ Make www-data usable by VS Code and login shells
RUN usermod -s /bin/bash -d /home/www-data www-data && \
    mkdir -p /home/www-data && \
    chown -R www-data:www-data /home/www-data

# ✅ Install git just in case
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

USER www-data

# Prod Stage
FROM build AS prod
USER root

# Build frontend and remove dev dependencies
RUN npm run build && \
    apt-get purge -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* node_modules

ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="false" \
    AUTORUN_LARAVEL_CONFIG_CACHE="true" \
    PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

USER www-data
