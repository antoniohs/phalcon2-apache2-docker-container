FROM ubuntu:15.10

MAINTAINER Antonio Manuel Hernández Sánchez

#Setting repositories and updating packages
RUN apt-get install -y software-properties-common;\
    apt-add-repository -y ppa:phalcon/stable;\
    apt-add-repository -y ppa:ondrej/apache2;\
    apt-get clean;\
    apt-get update -q;\
    apt-get upgrade -y --force-yes -q

#Installing Git, Php5, Apache2, curl
RUN apt-get install -y --force-yes -q git curl php5-phalcon php5-redis php5-intl php5-cli php5-xdebug php5-mysql php5-curl php5-mcrypt apache2 libapache2-mod-php5 supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Enabling mod_rewrite
RUN a2enmod rewrite

#Modifiying apache configuration
ADD apache-config /etc/apache2/sites-available/000-default.conf
ADD apache-config /etc/apache2/sites-available/default-ssl.conf
RUN ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
ADD 20-xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini
ADD 20-xdebug.ini /etc/php5/cli/conf.d/20-xdebug.ini
ADD 20-mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
ADD 20-mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
RUN ln -s /etc/php5/mods-available/phalcon.ini /etc/php5/cli/conf.d/30-phalcon.ini
RUN ln -s /etc/php5/mods-available/phalcon.ini /etc/php5/apache2/conf.d/30-phalcon.ini

#Creating self-signed certificate
RUN mkdir -p /etc/apache2/ssl/crt
RUN mkdir -p /etc/apache2/ssl/key
RUN openssl req -new -x509 -days 365 -keyout /etc/apache2/ssl/key/vhost1.key -out /etc/apache2/ssl/crt/vhost1.crt -nodes -subj '/O=VirtualHost Website Company name/OU=Virtual Host Website department/CN=www.virtualhostdomain.com'

#Enabling module ssl
RUN a2enmod ssl

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APPLICATION_ENV development

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN mkdir -p /deploy/releases/fake_release
RUN ln -s /deploy/releases/fake_release /deploy/current
RUN rm -rf /var/www
RUN ln -s /deploy/current /var/www

VOLUME /deploy

EXPOSE 80
EXPOSE 443

WORKDIR /var/www

CMD ["/usr/bin/supervisord"]
