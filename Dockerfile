FROM ubuntu:16.04
#RUN useradd -ms /bin/bash bala
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu -p Ab2424115
USER bala
RUN sudo apt-get -y update && apt-get -y upgrade
RUN sudo  apt-get -y install apache2 \
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
RUN apt-get install -y apache2 php libapache2-mod-php php-mcrypt php-mysql php-curl php-xml php-memcached
RUN service apache2 restart
WORKDIR /tmp/
RUN  wget https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.2.tar.gz
RUN tar -xvzf /tmp/mediawiki-1.34.2.tar.gz
RUN mkdir /var/lib/mediawiki
RUN mv mediawiki-1.34.2.tar.gz /var/lib/mediawiki
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
 && mkdir /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld

VOLUME ["/var/lib/mysql"]
EXPOSE 3306
CMD ["mysqld_safe"]
RUN systemctl enable mysql
