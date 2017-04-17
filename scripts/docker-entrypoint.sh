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

### Change PATH_ZMS under options:
##From "/cgi-bin/nph-zms" to "/zoneminder/cgi-bin/nph-zms"
mkdir /usr/lib/cgi-bin/nph-zms
ln -s /usr/lib/zoneminder/cgi-bin/nph-zms /usr/lib/cgi-bin/nph-zms
line_old3='ScriptAlias /zm/cgi-bin "/usr/lib/zoneminder/cgi-bin"'
line_new3='ScriptAlias /zoneminder/cgi-bin "/usr/lib/zoneminder/cgi-bin"'
sed -i "s%$line_old3%$line_new3%g" /etc/apache2/conf-available/zoneminder.conf

#Update php.ini to allow reverse proxing
wget -O /usr/share/zoneminder/www/index.php https://raw.githubusercontent.com/ToroNZ/doublec/master/scripts/php.ini

#Update MySQL settings to allow for some ZM table instructions
echo 'sql_mode = NO_ENGINE_SUBSTITUTION' >> /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl enable zoneminder
/etc/init.d/zoneminder start
/etc/init.d/apache2 restart

tail -F n0 /dev/null
