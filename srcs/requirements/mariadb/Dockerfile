FROM alpine:3.22.3

RUN apk add --no-cache mariadb mariadb-client \ 
    && mariadb-install-db --user=mysql --datadir=/var/lib/mysql \ 
    && mkdir -p /run/mysqld \ 
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql 

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]
