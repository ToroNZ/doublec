#!/bin/bash

echo "date.timezone = $PHP_TIMEZONE" >> /etc/php/7.0/apache2/php.ini

/etc/init.d/mysql start

mysql -u root < /usr/share/zoneminder/db/zm_create.sql
mysql -u root -e "GRANT ALL ON zm.* to 'zmuser'@localhost identified by 'zmpass';"
mysqladmin reload

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

systemctl enable zoneminder
/etc/init.d/zoneminder start
/etc/init.d/apache2 restart

tail -F n0 /dev/null
