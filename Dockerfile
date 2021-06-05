FROM debian:stretch

# PHP Repositorie (all versions)
RUN apt-get update && apt-get install -y wget gnupg2 ca-certificates apt-transport-https && wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

# Instalar Apache, PHP, etc
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl git zip unzip apache2 php{phpver} php{phpver}-curl php{phpver}-mbstring php{phpver}-xml php{phpver}-intl php{phpver}-zip php{phpver}-gd php{phpver}-mysql libapache2-mod-php{phpver} && apt-get clean && a2enmod php{phpver} && a2enmod rewrite && a2enmod ssl && sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/{phpver}/apache2/php.ini && sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/{phpver}/apache2/php.ini

# Constantes do Apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV APACHE_PID_FILE /var/run/apache2.pid

# Configurar Apache com nosso arquivo de vhost
COPY apache-tmp.conf /etc/apache2/sites-enabled/000-default.conf

# Copiar certificado SSL
COPY ssl/{host}/server.crt /etc/apache2/ssl/server.crt
COPY ssl/{host}/server.key /etc/apache2/ssl/server.key

# Portas
EXPOSE 80
EXPOSE 443

# Iniciar Apache como serviço
CMD /usr/sbin/apache2ctl -D FOREGROUND
