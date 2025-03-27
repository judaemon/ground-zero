# Base Image
FROM serversideup/php:8.3-fpm-nginx AS base
USER root

# Install system dependencies and Node.js in one layer
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -y && \
    apt-get install -y nodejs unzip && \
    rm -rf /var/lib/apt/lists/*

# For Laravel Reverb
EXPOSE 8000

# Unified build stage with environment-aware dependencies
FROM base AS build
ARG DEV_MODE=false
USER www-data
WORKDIR /var/www/html

# Install npm dependencies
COPY --chown=www-data:www-data package*.json ./
RUN npm install $( [ "$DEV_MODE" = "false" ] && echo "--production" )

# Install composer dependencies
COPY --chown=www-data:www-data composer*.json ./
RUN composer install --no-interaction --prefer-dist --optimize-autoloader \
    $( [ "$DEV_MODE" = "false" ] && echo "--no-dev" )

# Copy application code
COPY --chown=www-data:www-data . .

# Development image (retains all dependencies)
FROM build AS dev

FROM base AS prod
USER www-data
WORKDIR /var/www/html

# Copy built artifacts from build stage
COPY --from=build --chown=www-data:www-data /var/www/html/ .

# Build production assets and cleanup
USER root

# Build frontend assets
# RUN npm run build
    #  && \
    # npm uninstall -g npm && \
    # apt-get purge -y nodejs && \
    # apt-get autoremove -y && \
    # rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Production environment configuration
ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="false" \
    AUTORUN_LARAVEL_CONFIG_CACHE="true" \
    PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

USER www-data
