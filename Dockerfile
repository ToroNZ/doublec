FROM ubuntu
MAINTAINER Tomas Maggio <info@sensaway.co.nz>

ENV DEBIAN_FRONTEND=noninteractive

RUN add-apt-repository -y ppa:iconnor/zoneminder
RUN apt-get update
RUN apt-get install -y mysql-server \
    apache2 \
    php7.0 \
    libapache2-mod-php \
    php7.0-mysql \
    zoneminder


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

EXPOSE 80 443
