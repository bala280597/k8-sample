FROM ubuntu:16.04
#RUN useradd -ms /bin/bash bala
#USER bala


#Configure and install sql
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
 && mkdir /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld
VOLUME ["/var/lib/mysql"]
EXPOSE 3306
CMD ["mysqld_safe"]
RUN systemctl enable mysql

ENV ACCEPT_EULA Y
ENV sa_password balamurugan@123
COPY ./src/db.sql /docker-entrypoint-initdb.d/

