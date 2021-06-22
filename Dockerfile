FROM ubuntu:16.04

RUN apt update && apt install -y software-properties-common && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

RUN apt update && apt install -y \
    php5.6-fpm \
    php5.6-cli \
    php5.6-ctype \
    php5.6-curl \
    php5.6-dom \
    php5.6-gd \
    php5.6-iconv \
    php5.6-intl \
    php5.6-json \
    php5.6-ldap \
    php5.6-mcrypt \
    php5.6-memcache \
    php5.6-mysql \
    php5.6-mysqli \
    php5.6-opcache \
    php5.6-pdo \
    php5.6-mbstring \
    php-pear \
    php-xhprof \
    php5.6-pgsql \
    php5.6-phar \
    php5.6-sockets \
    php5.6-sqlite3 \
    php5.6-xml \
    php5.6-zip \
    git \
    curl \
    mariadb-common \
    mariadb-client 

RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/bin --filename=composer


RUN echo nameserver 8.8.8.8 > /etc/resolve.conf && \
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/bin/drupal && \
    chmod +x /usr/bin/drupal && \
    drupal init --destination /etc/console -q
RUN mkdir ~/drush8 && cd ~/drush8 && composer require drush/drush:8.*
RUN mkdir ~/drush9 && cd ~/drush9 && composer require drush/drush:9.*
RUN sed  -i "s/\(listen *= *\).*/\19000/" /etc/php/5.6/fpm/pool.d/www.conf && \
sed  -i "s/\(memory_limit *= *\).*/\1512M/" /etc/php/5.6/fpm/php.ini && \
sed  -i "s/\(max_execution_time *= *\).*/\1300/" /etc/php/5.6/fpm/php.ini && \
sed  -i "s/\(post_max_size *= *\).*/\12048M/" /etc/php/5.6/fpm/php.ini && \
sed  -i "s/\(upload_max_filesize *= *\).*/\12048M/" /etc/php/5.6/fpm/php.ini && \
echo "max_input_vars = 20000" >> /etc/php/5.6/fpm/php.ini && \
echo "date_timezone = America/Toronto" >> /etc/php/5.6/fpm/php.ini && \
sed  -i "s/\(^user *= *\).*/\1fedor/" /etc/php/5.6/fpm/pool.d/www.conf && \
sed  -i "s/\(^group *= *\).*/\1fedor/" /etc/php/5.6/fpm/pool.d/www.conf

RUN useradd fedor

EXPOSE 9000
EXPOSE 22

VOLUME ["/etc/php5/custom.d", "/app", "$HENCE_APP_VOL_PREFIX/conf", "$HENCE_APP_VOL_PREFIX/logs/php-general-logs", "$HENCE_APP_VOL_PREFIX/logs/php-error-logs","/vendor", "/config"]

WORKDIR /app

ENTRYPOINT service php5.6-fpm stop && service php5.6-fpm start && /bin/bash
