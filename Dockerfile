FROM ubuntu:16.04
#RUN useradd -ms /bin/bash bala
#RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 bala -p Ab2424115
#USER bala
RUN  apt-get -y update && apt-get -y upgrade
RUN   apt-get -y install apache2 \
                                php php-mysql\
                                libapache2-mod-php\
                                php-xml\
                                php-mbstring
RUN apt-get install -y php-apcu \
                              php-intl\
                              imagemagick\
                              inkscape\
                               php-gd\
                              php-cli\
                              php-curl\
                              git\
                              wget                  
RUN service apache2 restart

#Port expose and php deploy
WORKDIR /tmp/
EXPOSE 80

#mediawiki wget
RUN  wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.2.tar.gz
RUN tar -xvzf /tmp/mediawiki-1.33.2.tar.gz
RUN mkdir /var/lib/mediawiki
RUN mv mediawiki-*/* /var/lib/mediawiki
RUN ln -s /var/lib/mediawiki /var/www/html/mediawiki

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

#RUN mysql -u root
#RUN CREATE DATABASE my_wiki;
#RUN use my_wiki;
#RUN GRANT ALL ON my_wiki.* TO 'new_mysql_user'@'localhost';
#RUN exit;
