FROM alpine:3.22.3

RUN apk add --no-cache mariadb mariadb-client \ 
    && mariadb-install-db --user=mysql --datadir=/var/lib/mysql \ 
    && mkdir -p /run/mysqld \ 
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql 

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]
