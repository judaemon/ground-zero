# Dockerfile
############################################
# Base Image
############################################
ARG PHP_VERSION=8.3
FROM serversideup/php:${PHP_VERSION}-fpm-nginx AS base


############################################
# Development Image
############################################
FROM base AS development

# Switch to root so we can do root things
USER root

# Save the build arguments as a variable
ARG USER_ID
ARG GROUP_ID

# Install dev tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Use the build arguments to change the UID 
# and GID of www-data while also changing 
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data

# Copy dependency files first for layer caching
COPY --chown=www-data:www-data package.json package-lock.json* ./
COPY --chown=www-data:www-data composer.json composer.lock* ./

# Switch to www-data user for dependency installation
USER www-data

# Install npm and Composer dependencies
RUN npm install
RUN composer install --no-interaction --prefer-dist

# Copy the rest of the application files
COPY --chown=www-data:www-data . .

# Run Laravel setup and frontend build
RUN php artisan key:generate --force && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    npm run build


############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production

# Set working directory
WORKDIR /var/www/html

# Copy dependency files first for layer caching
COPY --chown=www-data:www-data package.json package-lock.json* ./
COPY --chown=www-data:www-data composer.json composer.lock* ./

# Install npm and Composer dependencies (production-optimized)
RUN npm install --production && npm cache clean --force
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Copy the rest of the application files
COPY --chown=www-data:www-data . .

# Run Laravel setup and frontend build for production
RUN php artisan key:generate --force && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    npm run build

# Ensure storage and cache directories are writable
RUN chmod -R 775 storage bootstrap/cache