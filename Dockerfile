FROM php:7.1.8-fpm

LABEL mantainer "hyyyyde"

# core library
RUN apt-get update -y \
    && apt-get install -y \
    git \
    libmecab-dev \
    libmcrypt-dev \
    libmysqlclient-dev \
    libpq-dev \
    libxslt-dev \
    mecab-ipadic \
    mecab-ipadic-utf8 \
    mecab \
    mysql-client \
    python-dev \
    redis-server \
    xz-utils \
    zip

# timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# APCu
RUN curl -fsSL https://pecl.php.net/get/apcu-5.1.3.tgz -o '/tmp/apcu.tar.gz' \
    && mkdir -p /usr/src/php/ext/apcu \
    && tar -xf /tmp/apcu.tar.gz -C /usr/src/php/ext/apcu --strip-components=1 \
    && rm /tmp/apcu.tar.gz \
    && docker-php-ext-configure apcu \
    && docker-php-ext-install apcu

# xdebug
RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.5.4.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    && cd ../ \
    && rm -rf xdebug \
    ) \
    && docker-php-ext-enable xdebug

# phpredis
ARG PHPREDIS_VERSION
RUN curl -OL https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && mkdir -p /usr/src/php/ext/phpredis \
    && tar -xf $PHPREDIS_VERSION.tar.gz -C /usr/src/php/ext/phpredis --strip-components=1 \
    && rm $PHPREDIS_VERSION.tar.gz \
    && docker-php-ext-configure phpredis \
    && docker-php-ext-install phpredis

# other php extention
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
    mbstring \
    mcrypt \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    xsl

# phing
RUN pear channel-discover pear.phing.info \
    && pear channel-discover pear.pdepend.org \
    && pear channel-discover pear.phpmd.org \
    && pear channel-discover components.ez.no \
    && pear channel-discover pear.symfony-project.com \
    && pear install phing/phing \
    && pear install phpmd/PHP_PMD

# phpcpd, phpcs, phpdox, pdpend, phploc, phpunit
RUN curl -OL https://phar.phpunit.de/phpcpd.phar \
    && chmod +x phpcpd.phar \
    && mv phpcpd.phar /usr/local/bin/phpcpd \
    && curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod +x phpcs.phar \
    && mv phpcs.phar /usr/local/bin/phpcs \
    && curl -OL https://github.com/theseer/phpdox/releases/download/0.9.0/phpdox-0.9.0.phar \
    && chmod +x phpdox-0.9.0.phar \
    && mv phpdox-0.9.0.phar /usr/local/bin/phpdox \
    && curl -OL http://static.pdepend.org/php/latest/pdepend.phar \
    && chmod +x pdepend.phar \
    && mv pdepend.phar /usr/local/bin/pdepend \
    && curl -OL https://phar.phpunit.de/phploc.phar \
    && chmod +x phploc.phar \
    && mv phploc.phar /usr/local/bin/phploc \
    && curl -OL https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit

# php-mecab
RUN git clone https://github.com/rsky/php-mecab.git \
    && cd php-mecab/mecab \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable mecab \
    && cd .. \
    && rm -rf php-mecab

# mecab辞書
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && cd mecab-ipadic-neologd/ \
    && mkdir -p /usr/lib/mecab/dic \
    && ./bin/install-mecab-ipadic-neologd -n -y \
    && cd .. \
    && rm -rf mecab-ipadic-neologd

# awscli
RUN curl -fsSL 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py \
    && python get-pip.py \
    && pip install --upgrade --user awscli \
    && rm -f get-pip.py \
    && echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo

# aws configuration
RUN mkdir -p /root/.aws
COPY .aws/* /root/.aws/

# php.ini
COPY php.ini /usr/local/etc/php/conf.d/

# user追加
RUN usermod -u 1000 www-data

# php-fpmソケット
RUN mkdir /var/run/php-fpm \
    && chown www-data:www-data /var/run/php-fpm

# php conf
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf
