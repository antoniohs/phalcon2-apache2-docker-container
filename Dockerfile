FROM ubuntu:14.04

MAINTAINER Antonio Manuel Hernández Sánchez

#Setting repositories and updating packages
RUN apt-get install -y software-properties-common;\
    apt-add-repository -y ppa:ondrej/php5-5.6;\
    apt-get clean;\
    apt-get update -q;\
    apt-get upgrade -y --force-yes -q

#Installing Git, Php5, Apache2
RUN apt-get install -y --force-yes -q php5-cli php5-mcrypt php5-curl php5-mysql php5-sqlite php5-memcached php5-xdebug php-apc git php5-dev apache2 libapache2-mod-php5 zend-framework php5-redis

#Installing Phalcon 2.0
RUN mkdir -p /tmp/phalcon
WORKDIR /tmp/phalcon
RUN git clone http://github.com/phalcon/cphalcon
WORKDIR /tmp/phalcon/cphalcon
RUN git checkout 2.0.0
RUN cd ext;./install
RUN echo 'extension=phalcon.so' > /etc/php5/apache2/conf.d/30-phalcon.ini
RUN echo 'extension=phalcon.so' > /etc/php5/cli/conf.d/30-phalcon.ini
RUN echo 'short_open_tag=On' > /etc/php5/apache2/conf.d/40-shortag.ini
RUN echo 'display_errors=On' > /etc/php5/apache2/conf.d/50-display_errors.ini


#Enabling mod_rewrite
RUN a2enmod rewrite

#Modifiying apache configuration
ADD apache-config /etc/apache2/sites-available/000-default.conf
ADD 20-xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini
ADD 20-xdebug.ini /etc/php5/cli/conf.d/20-xdebug.ini

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APPLICATION_ENV development

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

EXPOSE 80

VOLUME /var/www
WORKDIR /var/www

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-D", "FOREGROUND"]
