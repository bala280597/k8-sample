
FROM ubuntu:16.04
#RUN useradd -ms /bin/bash bala
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

#Port expose and php deploy
WORKDIR /tmp/
EXPOSE 80

#mediawiki deployment in apache2
RUN  wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.2.tar.gz
RUN tar -xvzf /tmp/mediawiki-1.33.2.tar.gz
RUN mkdir /var/lib/mediawiki
RUN mv mediawiki-*/* /var/lib/mediawiki
RUN ln -s /var/lib/mediawiki /var/www/html/mediawiki

FROM mysql
ENV MYSQL_DATABASE my_wiki
ENV MYSQL_USER balamurugan
ENV MYSQL_PASSWORD balamurugan@123

