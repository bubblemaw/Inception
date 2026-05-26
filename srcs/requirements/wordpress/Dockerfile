FROM alpine:3.22.4

RUN apk add --no-cache wget
RUN apk add php8.3 php-fpm php-mysql mariadb-client

RUN apk add tar
RUN wget https://fr.wordpress.org/wordpress-6.9.4-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.9.4-fr_FR.tar.gz && rm wordpress-6.9.4-fr_FR.tar.gz
RUN chown -R root:root /var/www/wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

ENTRYPOINT 


