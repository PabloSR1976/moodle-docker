FROM php:8.4-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    && docker-php-ext-install \
    pdo_mysql \
    mysqli \
    gd \
    intl \
    zip \
    xml \
    mbstring \
    curl \
    soap \
    opcache \
    && a2enmod rewrite headers

# Configurar Apache para Moodle
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
RUN echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/moodle.ini

# Descargar Moodle
WORKDIR /var/www/html
RUN wget -O moodle.tgz https://download.moodle.org/download.php/direct/stable501/moodle-latest-501.tgz \
    && tar -xzf moodle.tgz --strip-components=1 \
    && rm moodle.tgz \
    && chown -R www-data:www-data . \
    && chmod -R 755 .

EXPOSE 80
CMD ["apache2-foreground"]
