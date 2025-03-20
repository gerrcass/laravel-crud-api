#!/bin/bash

# Mostrar información de debug
echo "Starting Laravel application..."

# Verificar variables de entorno críticas
echo "Checking environment variables..."
env | grep -E "APP_|DB_"

# Agregar verificación de variables críticas
for var in APP_KEY DB_HOST DB_DATABASE DB_USERNAME DB_PASSWORD DB_SSLMODE; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

# Run migrations
echo "Running migrations..."
php artisan migrate --force || exit 1

# Esperar a que la base de datos esté disponible
echo "Waiting for database connection..."
max_tries=30
counter=0
until php artisan db:monitor || [ $counter -gt $max_tries ]; do
    echo "Waiting for database connection..."
    sleep 2
    counter=$((counter + 1))
done

if [ $counter -gt $max_tries ]; then
    echo "Error: Database connection timeout"
    exit 1
fi

# Cache configuration after environment variables are set
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache


# Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm -D

# Start Nginx
echo "Starting Nginx..."
nginx -g "daemon off;" 