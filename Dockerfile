FROM php:8.0-fpm-buster


# Copy composer.lock and composer.json
# COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    bash \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libwebp-dev \
    libjpeg-dev \
    libtiff-dev \
    libgif-dev \
    webp \
    openssl \
    libssl-dev \
    wget

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
 
COPY docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Install extensions
RUN docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include
RUN docker-php-ext-install gd
RUN docker-php-ext-install opcache
RUN docker-php-ext-configure intl \
	&& docker-php-ext-install intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN composer self-update 1.6.5

# Add user for laravel application
RUN groupadd -g 1005 www
RUN useradd -u 1005 -ms /bin/bash -g www www
RUN usermod -a -G www-data www

#RUN a2enmod rewrite

RUN cd /tmp && wget https://pecl.php.net/get/swoole-4.6.4.tgz && \
    tar zxvf swoole-4.6.4.tgz && \
    cd swoole-4.6.4  && \
    phpize  && \
    ./configure  --enable-openssl && \
    make && make install

RUN touch /usr/local/etc/php/conf.d/swoole.ini && \
    echo 'extension=swoole.so' > /usr/local/etc/php/conf.d/swoole.ini



# Copy existing application directory contents
#COPY . /var/www/html

# Copy existing application directory permissions
#COPY --chown=www:www . /var/www/html

#RUN chown -R www-data:www-data /var/www/html/storage/framework
#RUN chown -R www-data:www-data /var/www/html/storage/logs


USER www

EXPOSE 1215
