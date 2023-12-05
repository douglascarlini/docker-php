FROM debian:bullseye

RUN apt-get update && apt-get install -y wget gnupg2 ca-certificates apt-transport-https && wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && echo "deb https://packages.sury.org/php/ bullseye main" | tee /etc/apt/sources.list.d/php.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y composer curl git zip unzip apache2 php8.1 php8.1-fpm php8.1-curl php8.1-bcmath php8.1-soap php8.1-mbstring php8.1-xml php8.1-intl php8.1-zip php8.1-gd php8.1-imagick php8.1-mysql libapache2-mod-php8.1 && apt-get clean && a2enmod php8.1 && a2enmod rewrite && a2enmod ssl && sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.1/apache2/php.ini && sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.1/apache2/php.ini

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV APACHE_PID_FILE /var/run/apache2.pid

COPY apache-tmp.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /etc/php/8.1/apache2/php.ini

CMD /usr/sbin/apache2ctl -D FOREGROUND