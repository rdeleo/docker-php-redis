# Ubuntu container with php 7 and redis component
#
# VERSION               0.0.1

FROM        ubuntu:16.04
MAINTAINER  Riccardo De Leo <riccardo.deleo@covianalytics.com>

WORKDIR     /
ARG fileConf


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils git apache2 \
    php7.0 php7.0-cli php7.0-common php7.0-curl php7.0-dev php7.0-gd \
    php7.0-json php7.0-ldap php7.0-mysql php7.0-opcache php7.0-pspell \
    php7.0-readline php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xml \
    php7.0-xmlrpc php-all-dev php7.0-bcmath php7.0-bz php7.0-intl\
    php7.0-mbstring php7.0-mcrypt php7.0-zip php7.0-xsl libapache2-mod-php7.0

#Install redis extension
RUN git clone -b php7 https://github.com/phpredis/phpredis.git
RUN mv /phpredis /etc/phpredis
RUN cd /etc/phpredis && \
    phpize && \
    ./configure &&\
    make && make install
RUN echo "extension=/etc/phpredis/modules/redis.so" > /etc/php/7.0/apache2/conf.d/10-redis.ini
RUN echo "extension=/etc/phpredis/modules/redis.so" > /etc/php/7.0/cli/conf.d/10-redis.ini

#@TODO: EDIT THE STATIC USER ID 1000 DO $UID
RUN usermod -u 1000 www-data

COPY ./$fileConf /etc/apache2/sites-available/000-default.conf

# Configure localhost in Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN a2enmod rewrite

# Define default command
CMD ["apachectl", "-D", "FOREGROUND"]