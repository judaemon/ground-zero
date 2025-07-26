# Dockerfile
############################################
# Base Image
############################################
ARG PHP_VERSION=8.3
FROM serversideup/php:${PHP_VERSION}-fpm-nginx AS base

# Switch to root to install dependencies
USER root

# Install Node.js, npm, and dev tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    curl \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set working directory
WORKDIR /var/www/html

############################################
# Development Image
############################################
FROM base AS development

# Switch to root for system-level changes
USER root

# Save build arguments as variables
ARG USER_ID=1000
ARG GROUP_ID=1000

# Modify www-data user and group to match host UID/GID
RUN usermod -u ${USER_ID} www-data && \
    groupmod -g ${GROUP_ID} www-data && \
    chown -R www-data:www-data /var/www && \
    usermod -s /bin/bash www-data

# Set file permissions for NGINX and Laravel directories
RUN docker-php-serversideup-set-id www-data ${USER_ID}:${GROUP_ID} && \
    docker-php-serversideup-set-file-permissions --owner ${USER_ID}:${GROUP_ID} --service nginx && \
    # Ensure Laravel storage and cache directories are writable
    mkdir -p storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Switch to www-data user
USER www-data

# Copy dependency files for layer caching
COPY --chown=www-data:www-data composer.json composer.lock* package.json package-lock.json* ./

# Copy the rest of the application files
COPY --chown=www-data:www-data . .


############################################
# Production Image
############################################
FROM base AS production

# Copy dependency files for layer caching
COPY --chown=www-data:www-data composer.json composer.lock* package.json package-lock.json* ./

# Install production dependencies
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader && \
    npm install --production && \
    npm cache clean --force

# Copy the rest of the application
COPY --chown=www-data:www-data . .

# Run Laravel setup and frontend build
RUN php artisan key:generate --force && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    npm run build

# Ensure storage and cache directories are writable
USER root
RUN mkdir -p storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

USER www-data