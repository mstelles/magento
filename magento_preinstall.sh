#!/bin/bash

echo "installing nginx, php and dependencies"
apt-get update
apt-get install -y nginx zip php7.2 php-xml php7.2-mbstring php7.2-curl php7.2-bcmath php7.2-zip php7.2-gd php7.2-intl php7.2-mysql php7.2-soap php7.2-fpm

# nginx config
echo "
upstream fastcgi_backend {
  server  unix:/run/php/php7.2-fpm.sock;
}

server {

  listen 80;
  server_name www.magento-dev.com;
  set $MAGE_ROOT /var/www/html/magento2;
  include /var/www/html/magento2/nginx.conf.sample;
}
" > /etc/nginx/sites-available/magento
ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default-$(date +%Y-%m-%d_%H:%M)
sed s/"root \/var\/www\/html\/"/"root \/var\/www\/html\/magento2\/"/g /etc/nginx/sites-available/default > /etc/nginx/sites-available/default-new
mv /etc/nginx/sites-available/default-new /etc/nginx/sites-available/default

# php config
echo "configuring php"
cp /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php-$(date +%Y-%m-%d_%H:%M).ini
cp /etc/php/7.2/cli/php.ini /etc/php/7.2/cli/php-$(date +%Y-%m-%d_%H:%M).ini

sed -e s/"max_execution_time = 30"/"max_execution_time = 1800"/g -e s/"memory_limit = 128M"/"memory_limit = 2G"/g -e s/"zlib.output_compression = Off"/"zlib.output_compression = On"/g /etc/php/7.2/fpm/php.ini > /etc/php/7.2/fpm/php-new.ini
sed -e s/"max_execution_time = 30"/"max_execution_time = 1800"/g -e s/"memory_limit = 128M"/"memory_limit = 2G"/g -e s/"zlib.output_compression = Off"/"zlib.output_compression = On"/g /etc/php/7.2/cli/php.ini > /etc/php/7.2/cli/php-new.ini

mv /etc/php/7.2/fpm/php-new.ini /etc/php/7.2/fpm/php.ini
mv /etc/php/7.2/cli/php-new.ini /etc/php/7.2/cli/php.ini

systemctl enable nginx
systemctl start nginx
systemctl restart php7.2-fpm

echo "install and configure MySQL"
apt-get install -y mysql-server mysql-client
systemctl enable mysql
systemctl start mysql

cat << EOF | mysql
CREATE DATABASE magento;
CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento';
GRANT ALL PRIVILEGES ON magento.* TO 'magento'@'localhost';
EOF
