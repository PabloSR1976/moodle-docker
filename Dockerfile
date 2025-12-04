FROM php:8.1-apache

# Instalar extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev \
    && docker-php-ext-install pdo_mysql mysqli gd intl zip xml mbstring opcache \
    && a2enmod rewrite

# Configurar PHP para Moodle
RUN echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/moodle.ini
RUN echo 'upload_max_filesize = 128M' >> /usr/local/etc/php/conf.d/moodle.ini
RUN echo 'post_max_size = 128M' >> /usr/local/etc/php/conf.d/moodle.ini

# Configurar Apache automáticamente
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Descargar Moodle 5.1
WORKDIR /var/www/html
RUN curl -sL https://download.moodle.org/download.php/direct/stable501/moodle-latest-501.tgz -o moodle.tgz \
    && tar -xzf moodle.tgz --strip-components=1 \
    && rm moodle.tgz \
    && chown -R www-data:www-data .

EXPOSE 80
CMD ["apache2-foreground"]
