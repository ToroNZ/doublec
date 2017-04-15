#!/bin/bash

echo "date.timezone = Pacific/Auckland" >> /etc/php/7.0/apache2/php.ini

/etc/init.d/mysql start

mysql -u root < /usr/share/zoneminder/db/zm_create.sql
mysql -u root -e "GRANT ALL ON zm.* to 'zmuser'@localhost identified by 'zmpass';"
mysqladmin reload

systemctl enable zoneminder
/etc/init.d/zoneminder start
/etc/init.d/apache2 restart

tail -F n0 /dev/null
