#! /bin/sh

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]  && [ -n "$SQL_DATABASE"]; then

    mariadbd-safe --datadir=/var/lib/mysql &

    while ! mariadb-admin ping 2>/dev/null; do
        sleep 1
    done

    sleep 3

    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

    mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    mariadb -e "FLUSH PRIVILEGES";

    mariadb-admin -u root -p"$SQL_ROOT_PASSWORD" --socket=/run/mysqld/mysqld.sock shutdown
    sleep 1
    # cat /var/lib/mysql/*.err
fi

exec mariadbd-safe --datadir=/var/lib/mysql