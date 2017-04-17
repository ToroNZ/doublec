FROM ubuntu
MAINTAINER Tomas Maggio <info@sensaway.co.nz>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y software-properties-common wget
RUN add-apt-repository -y ppa:iconnor/zoneminder
RUN apt-get update
RUN apt-get install -y mysql-server \
    apache2 \
    php7.0 \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-curl \
    php7.0-gd \
    php7.0-intl \
    php-pear \
    php-imagick \
    php7.0-imap \
    php7.0-mcrypt \
    php-memcache \
    php7.0-pspell \
    php7.0-recode \
    php7.0-sqlite3 \
    php7.0-tidy \
    php7.0-xmlrpc \
    php7.0-xsl \
    php7.0-mbstring \
    php-gettext \
    php-apcu \
    php-gd \
    zoneminder
RUN apt-get clean


RUN adduser www-data video
RUN chmod 740 /etc/zm/zm.conf
RUN chown root:www-data /etc/zm/zm.conf
RUN chown -R www-data:www-data /usr/share/zoneminder

RUN a2enconf zoneminder
RUN a2enmod cgi
RUN a2enmod rewrite

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 777 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
