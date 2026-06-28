#! /bin/sh

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then

    mariadbd-safe --datadir=/var/lib/mysql &
    sleep 3

    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

    mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    mariadb -e "FLUSH PRIVILEGES";

    mariadb-admin -u root -p${MYSQL_ROOT_PASSWORD} --socket=/run/mysqld/mysqld.sock shutdown
    sleep 1
    
fi

exec mariadbd-safe --datadir=/var/lib/mysql