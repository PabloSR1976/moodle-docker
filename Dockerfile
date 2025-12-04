FROM php:8.4-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP necesarias para Moodle
RUN docker-php-ext-install \
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
    pdo_pgsql

# Instalar extensiones PECL si es necesario
# RUN pecl install redis && docker-php-ext-enable redis

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl

# Configurar php.ini para Moodle (optimizado para PHP 8.4)
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 128M'; \
    echo 'post_max_size = 128M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_vars = 5000'; \
    echo 'max_input_time = 300'; \
    echo 'display_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /var/log/php_error.log'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.max_accelerated_files = 10000'; \
    echo 'opcache.revalidate_freq = 2'; \
} > /usr/local/etc/php/conf.d/moodle.ini

# Crear directorio para Moodle
WORKDIR /var/www/html

# Descargar Moodle 5.1
RUN curl -L https://download.moodle.org/download.php/direct/stable501/moodle-latest-501.tgz -o moodle.tgz \
    && tar -xzf moodle.tgz --strip-components=1 \
    && rm moodle.tgz

# Configurar permisos (seguro para producción)
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Crear directorio para logs de Apache
RUN mkdir -p /var/log/apache2 && chown www-data:www-data /var/log/apache2

# Puerto expuesto
EXPOSE 80
EXPOSE 443

# Salud check para Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Comando por defecto
CMD ["apache2-foreground"]
