FROM ubuntu:18.04

MAINTAINER FimaL <fimal@radware.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update

RUN apt-get install -y apt-utils && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get -y update

RUN apt-get install -y\
    apache2 \
    php5.6 \
    php5.6-mysqlnd \
    wget \
    unzip \
    curl 

WORKDIR /var/www/html/

# copy supervisor configuration
#COPY ./bwapp_front.conf /etc/supervisor/conf.d/bwapp.conf

# download bWAPP
RUN wget http://jaist.dl.sourceforge.net/project/bwapp/bWAPP/bWAPP_latest.zip && unzip bWAPP_latest.zip &&\
    rm /var/www/html/index.html bWAPP_latest.zip

ENV MYSQL_ROOT_PASSWORD bug
ENV MYSQL_IP 172.17.0.2

# Setup
RUN sed -i 's/db_password = ""/db_password = "'$MYSQL_ROOT_PASSWORD'"/g' bWAPP/admin/settings.php
RUN sed -i 's/db_server = "localhost"/db_server = "'$MYSQL_IP'"/g' bWAPP/admin/settings.php

# install bWAPP
RUN /etc/init.d/apache2 restart &&\
  curl http://127.0.0.1/bWAPP/install.php?install=yes 1>/dev/null

EXPOSE 80

CMD ["/usr/sbin/apachectl","-DFOREGROUND"]
# start supervisord
#CMD ["/usr/bin/supervisord"]
