# Base Image
FROM serversideup/php:8.3-fpm-nginx AS base
USER root

# Install system dependencies and Node.js in one layer
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs unzip git && \
    rm -rf /var/lib/apt/lists/*

# Build Stage (common for all environments)
FROM base AS build
ARG DEV_MODE=false
USER www-data
WORKDIR /var/www/html

# Install Node.js and Composer dependencies first for better caching
COPY --chown=www-data:www-data package.json package-lock.json ./
RUN npm install --production

COPY --chown=www-data:www-data composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy the full application code after dependencies are installed
COPY --chown=www-data:www-data ./ /var/www/html

# Run additional installations if in development mode
RUN if [ "$DEV_MODE" = "true" ]; then \
    composer install --no-dev --optimize-autoloader; \
else \
    composer install --no-interaction --prefer-dist; \
fi

# Development Image (keeps Node.js and all dev dependencies)
FROM build AS dev
USER www-data

# Production Image (removes Node.js after asset build)
FROM build AS prod
USER root

# Build frontend assets
RUN npm run build && \
    npm uninstall -g npm && \
    apt-get purge -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    rm -rf node_modules

# Set production environment variables
ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="false" \
    AUTORUN_LARAVEL_CONFIG_CACHE="true" \
    PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

USER www-data
