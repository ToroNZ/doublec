#!/bin/bash

#Comment out if passing a variable from Dockerfile
#echo "date.timezone = $PHP_TIMEZONE" >> /etc/php/7.0/fpm/php.ini
sed -i 's/\;date.timezone =/date.timezone = \"Pacific\/Auckland\"/'

/etc/init.d/mysql start

mysql -u root < /usr/share/zoneminder/db/zm_create.sql
mysql -u root -e "GRANT ALL ON zm.* to 'zmuser'@localhost identified by 'zmpass';"
mysqladmin reload

#Set NTP Timezone
service ntp start
#timedatectl set-timezone Pacific/Auckland

#Change nginx conf to reflect new domain instance
sed -i 's/example.com/$WWW_DOMAIN/' /etc/nginx/conf.d/backend.conf

### Customize ZM
# Update Main page title
line_old='<h2 id="title"><a href="http://www.zoneminder.com" target="ZoneMinder">ZoneMinder</a>'
line_new='<h2 id="title"><a href="https://www.doublec.tv" target="DoubleC">DoubleC.tv</a>'
sed -i "s%$line_old%$line_new%g" /usr/share/zoneminder/www/skins/classic/views/console.php

# Favicon
wget -O /usr/share/zoneminder/www/graphics/favicon.ico "https://filer.sensaway.co.nz/f/a8a654f726/?dl=1"

# Change browser tab title
line_old1='<title><?php echo ZM_WEB_TITLE_PREFIX ?></title>'
line_new1='<title>DoubleC.tv - Console</title>'
sed -i "s%$line_old1%$line_new1%g" /usr/share/zoneminder/www/skins/classic/views/none.php
line_old2='<title><?php echo ZM_WEB_TITLE_PREFIX ?> - <?php echo validHtmlStr($title) ?></title>'
line_new2='<title>DoubleC.tv - Console</title>'
sed -i "s%$line_old2%$line_new2%g" /usr/share/zoneminder/www/skins/classic/includes/functions.php

#Update php.ini to allow reverse proxing
wget -O /usr/share/zoneminder/www/index.php https://raw.githubusercontent.com/ToroNZ/doublec/master/scripts/php.ini

#Initialize MariaDB setup
sudo mysql_secure_installation
#Install ZM
sudo apt-get install zoneminder
#Set permissions
sudo chmod 740 /etc/zm/zm.conf
sudo chown root:www-data /etc/zm/zm.conf
sudo chown www-data /dev/shm
sudo chown -R www-data:www-data /usr/share/zoneminder
sudo chown -R www-data:www-data /var/cache/zoneminder
sudo a2enmod cgi
sudo a2enconf zoneminder
sudo a2enmod rewrite
#Update MySQL settings to allow for some ZM table instructions
echo 'sql_mode = NO_ENGINE_SUBSTITUTION' >> /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl enable zoneminder
sudo systemctl restart mysql
sudo systemctl start zoneminder
sudo systemctl reload nginx

tail -F n0 /dev/null
