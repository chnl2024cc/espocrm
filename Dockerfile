# Base image: PHP + Apache
FROM php:8.2-apache

# Install required system libs & PHP extensions
RUN apt-get update && apt-get install -y \
	cron \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql intl zip bcmath soap opcache exif \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy custom PHP settings for web (Apache SAPI)
COPY php-web.ini /usr/local/etc/php/conf.d/custom.ini

# Set working dir
WORKDIR /var/www/html

# Copy repo files into image
COPY . .

# Copy crontab file
COPY my-cron /etc/cron.d/my-cron

# Give proper permissions and load crontab
RUN chmod 0644 /etc/cron.d/my-cron \
    && crontab /etc/cron.d/my-cron
	
# Ensure cron logs somewhere
RUN touch /var/log/cron.log

# Fix ownership and mark safe for Git
RUN chown -R www-data:www-data /var/www/html \
    && git config --global --add safe.directory /var/www/html

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Install Node.js
RUN apt-get update && apt-get install -y nodejs npm

# Install frontend dependencies
RUN npm install

# Build frontend
RUN npm run build

EXPOSE 80

# Start cron and Apache in foreground
CMD ["sh", "-c", "cron && apache2-foreground"]
