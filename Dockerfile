FROM wordpress:php8.1-apache

# Copy WordPress files to the container
COPY ./wordpress/ /var/www/html/blog

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nano \
    wget \
    gzip \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zlib1g-dev \
    && apt-get clean

# Install Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# Download and install ionCube Loader
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzf ioncube_loaders_lin_x86-64.tar.gz \
    && cp ioncube/ioncube_loader_lin_8.1.so $(php-config --extension-dir) \
    && echo "zend_extension=$(php-config --extension-dir)/ioncube_loader_lin_8.1.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf ioncube_loaders_lin_x86-64.tar.gz ioncube

# Clean extra files for optimization
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Activate Apache rewrite module
RUN a2enmod rewrite headers

# Set correct ownership for WordPress files
RUN chown -R www-data:www-data /var/www/html/blog

# Set correct permissions for WordPress files
RUN find /var/www/html/blog -type d -exec chmod 755 {} \;
RUN find /var/www/html/blog -type f -exec chmod 644 {} \;

# Add the custom wp-config.php logic for https handling
RUN echo "if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') { \$_SERVER['HTTPS'] = 'on'; }" >> /var/www/html/blog/wp-config.php

# Define volumes for persistent data storage
VOLUME ["/var/www/html/blog/wp-content"]

# Set the working directory
WORKDIR /var/www/html/blog
