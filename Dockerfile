FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

## Install php nginx mysql supervisor
RUN apt update && \
    apt install -y php-fpm php-cli php-gd php-mcrypt php-mysql php-curl php-mbstring php-xml php-mbstring php-zip\
                       nginx \
                       curl \
                       git \
                       vim \
		       supervisor && \
    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt install -y mysql-server && \
    rm -rf /var/lib/apt/lists/*

## Configuration
RUN sed -i 's/^listen\s*=.*$/listen = 127.0.0.1:9000/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cgi.log/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cli.log/' /etc/php/7.0/cli/php.ini && \
    sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy nginx and supervisor configuration
COPY files/root /

# Copy google metadata application code
COPY app /var/www

VOLUME /var/www/

#RUN composer global require "laravel/installer"

#RUN /root/.composer/vendor/bin/laravel new google-metadata

WORKDIR /var/www/google-metadata

#RUN composer require padosoft/laravel-google-structured-data-testing-tool

# Install laravel dependencies
RUN composer install

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
