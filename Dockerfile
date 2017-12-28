FROM tgbyte/nginx-php-fpm
MAINTAINER Thilo-Alexander Ginkel <thilo@ginkel.com>

ENV SELF_URL_PATH=http://localhost \
    DB_NAME=ttrss \
    DB_USER=ttrss \
    DB_PASS=ttrss \
    TTRSS_SOURCE_TAR_URL=https://git.tt-rss.org/git/tt-rss/archive/17.4.tar.gz \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  php7.0-curl php7.0-gd php7.0-json php7.0-pgsql php7.0-mysql php7.0-mcrypt && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# enable the mcrypt module
RUN phpenmod mcrypt

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/conf.d/ttrss.conf

# install ttrss and patch configuration
WORKDIR /var/www
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl --no-install-recommends && rm -rf /var/lib/apt/lists/* \
    && curl -SL ${TTRSS_SOURCE_TAR_URL} | tar xzC /var/www --strip-components 1 \
    && apt-get purge -y --auto-remove curl \
    && chown www-data:www-data -R /var/www \
    && cp config.php-dist config.php

WORKDIR /var/tmp

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD entrypoint.d/ /entrypoint.d
ADD configure-db.php /configure-db.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf.d/ttrss-update-daemon.conf
