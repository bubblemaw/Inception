FROM alpine:3.22.4

RUN apk add --no-cache wget
RUN apk add --no-cache \
            php83 \
            php83-fpm \
            php83-json \
            php83-curl \
            php83-dom \
            php83-xml \
            php83-mbstring \
            php83-session \
            php83-openssl \
            php83-mysqli \
            mariadb-client \
            php83-phar

RUN apk add tar
RUN wget https://fr.wordpress.org/wordpress-6.9.4-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.9.4-fr_FR.tar.gz && rm wordpress-6.9.4-fr_FR.tar.gz
RUN chown -R root:root /var/www/wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/init.sh /init.sh

RUN chmod +x init.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

CMD ["/init.sh"]


