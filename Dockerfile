# Dockerfile
#PHP Apache docker image for php8.2
FROM php:8.1-apache-bullseye

#adds library support for different image upload
RUN apt update && apt install -y zlib1g-dev \
    libpng-dev libwebp-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libmagickwand-dev \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \
    && docker-php-ext-enable imagick

RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath
#adds gd library support for different image upload
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype
RUN docker-php-ext-install gd

#000-default.conf is used to configure the web-server to listen to port 80 which Cloud run requires
# COPY --from=build /app /var/www/
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN mkdir -p /home/www-data/.composer && \
    chown -R www-data:www-data /home/www-data

# Add the composer.json
COPY ./composer.* ./
COPY ./database ./database
RUN composer install --prefer-dist --no-scripts -q -o


WORKDIR /var/www
COPY . .

COPY docker-compose/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod 777 -R /var/www/storage/ && \
    echo "Listen 8080">>/etc/apache2/ports.conf && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite
# RUN composer require --dev barryvdh/laravel-ide-helpe & composer dump-autoload & composer install --classmap-authoritative --no-dev


EXPOSE 80
user www-data
