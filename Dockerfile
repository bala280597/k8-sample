FROM ubuntu:16.04

RUN apt-get update && \
      apt-get -y install sudo

RUN \
    groupadd -g 999 bala && useradd -u 999 -g bala -G sudo -m -s /bin/bash bala && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "bala ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the bala user!" && \
    echo "bala user:";  su - bala -c id

# switch user bala
USER bala
RUN  sudo apt-get -y update 


RUN  sudo apt-get -y update && apt-get -y upgrade

#Install php apache packages
RUN   sudo apt-get -y install apache2 \
                                php php-mysql\
                                libapache2-mod-php\
                                php-xml\
                                php-mbstring
RUN sudo apt-get install -y php-apcu \
                              php-intl\
                              imagemagick\
                              inkscape\
                               php-gd\
                              php-cli\
                              php-curl\
                              git\
                              wget                  



#Port expose and php deploy
WORKDIR /tmp/
EXPOSE 80

#mediawiki deployment in apache2
RUN  wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.2.tar.gz
RUN tar -xvzf /tmp/mediawiki-1.33.2.tar.gz
RUN mkdir /var/lib/mediawiki
RUN mv mediawiki-*/* /var/lib/mediawiki
RUN ln -s /var/lib/mediawiki /var/www/html/mediawiki


#Configure and install sql
RUN sudo apt-get update \
 && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mysql-server \
 && sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
 && sudo mkdir /var/run/mysqld \
 && sudo chown -R mysql:mysql /var/run/mysqld
#volume
VOLUME ["/var/lib/mysql"]
EXPOSE 3306

CMD ["mysqld_safe"]
RUN systemctl enable mysql
RUN mysql -u root;\
CREATE USER 'balamurugan'@'localhost' IDENTIFIED BY 'balamurugan@123';\
CREATE DATABASE wikidatabase;\
GRANT ALL PRIVILEGES ON wikidatabase.* TO 'balamurugan'@'localhost';

#restart the apache server foreground
CMD ["apachectl", "-D", "FOREGROUND"]

