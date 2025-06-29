# Base Image
FROM serversideup/php:8.3-fpm-nginx AS base
USER root

# Install system dependencies and Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs unzip git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Build Stage
FROM base AS build
USER www-data

# Copy package files first
COPY --chown=www-data:www-data package*.json ./
RUN npm install

COPY --chown=www-data:www-data composer.* ./
RUN composer install --no-interaction --prefer-dist

COPY --chown=www-data:www-data ./ ./

FROM build AS local
USER root

RUN usermod -s /bin/bash -d /home/www-data www-data && \
    mkdir -p /home/www-data && \
    chown -R www-data:www-data /home/www-data

# Ensure git is present in case devs need it inside container
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

USER www-data

# Production Stage
FROM build AS prod
USER root

# Build frontend and cleanup
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
