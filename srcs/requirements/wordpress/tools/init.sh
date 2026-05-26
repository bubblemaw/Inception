#! /bin/sh

sleep 10

wp config create --allow-root \ 
                --dbname=$SQL_DATABASE \
                --dbuser=$SQL_USER \
                --dbpass=$SQL_PASSWORD \
                --dbhost=mariadb:3306 \
                --path='/var/www/wordpress'

wp core install --allow-root \
                --url=$DOMAIN_NAME \
                --title=$SITE_TITLE \
                --admin_user=$ADMIN_USER \
                --admin_password=$ADMIN_PASSWORD \
                --admin_email=$ADMIN_EMAIL \
                --path=/var/www/wordpress
                

wp user create --allow-root \
            $WP_USER \
            $WP_USER_EMAIL \
            --role=author \
            --user-pass=$WP_USER_PASSWORD \
            --path=/var/www/wordpress

mkdir -p /run/php

exec php-fpm