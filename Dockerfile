# Stage 1: Composer dependencies
FROM composer:latest as composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY . .
RUN composer dump-autoload --optimize


# Stage 2: PHP-FPM and Nginx application server
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    nginx \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP and Nginx
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf

# Copy application
WORKDIR /var/www/html
COPY --from=composer /app .

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configure logs
RUN mkdir -p /var/log/nginx /var/log/php-fpm /var/www/html/storage/logs && \
    chown -R www-data:www-data /var/log/nginx /var/log/php-fpm /var/www/html/storage && \
    chmod -R 775 /var/log/nginx /var/log/php-fpm /var/www/html/storage

# Copy and set start script
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/health || exit 1

