#!/bin/bash

# Check if .env file exists, if not copy from .env.example
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
else
    echo ".env file already exists"
fi

# Install PHP dependencies if vendor directory doesn't exist
if [ ! -d vendor ]; then
    composer install
    echo "Installed PHP dependencies"
else
    echo "PHP dependencies already installed, skipping composer install"
fi

# Install Node.js dependencies if node_modules directory doesn't exist
if [ ! -d node_modules ]; then
    npm install
    echo "Installed Node.js dependencies"
else
    echo "Node.js dependencies already installed, skipping npm install"
fi

# Build frontend assets if build directory/file doesn't exist (adjust based on your build output)
if [ ! -d public/build ]; then
    npm run build
    echo "Built frontend assets"
else
    echo "Frontend assets already built, skipping npm run build"
fi

# Generate Laravel application key
php artisan key:generate --force
echo "Generated Laravel application key"

# Run database migrations
php artisan migrate --force
echo "Ran database migrations"