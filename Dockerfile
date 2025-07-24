# Dockerfile
############################################
# Base Image
############################################
ARG PHP_VERSION=8.3
FROM serversideup/php:${PHP_VERSION}-fpm-nginx AS base

# Switch to root to install Node.js
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

############################################
# Development Image
############################################
FROM base AS development

# Switch to root so we can do root things
USER root

# Save the build arguments as a variable
ARG USER_ID=1000
ARG GROUP_ID=1000

# Set working directory
WORKDIR /var/www/html

# Use the build arguments to change the UID 
# and GID of www-data while also changing 
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Switch to www-data
USER www-data

# Copy dependency files first for layer caching
COPY --chown=www-data:www-data package.json package-lock.json* ./ 
COPY --chown=www-data:www-data composer.json composer.lock* ./

# Install dependencies
RUN composer install --no-interaction --prefer-dist && \
    npm install

RUN echo "Running npm run dev..."

# Copy the rest of the application files
COPY --chown=www-data:www-data . .


############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production

# Copy dependency files for layer caching
COPY --chown=www-data:www-data composer.json composer.lock* package.json package-lock.json* ./

# Install production dependencies
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader && \
    npm install --production && npm cache clean --force

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
RUN chmod -R 775 storage bootstrap/cache

USER www-data
