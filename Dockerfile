FROM php:7.1-apache

# 1. Fix legacy Debian repositories (E-O-L)
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

# 2. Install PHP extensions (GD, MySQLi, PDO, Mbstring, XML, Curl)
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev curl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd mysqli pdo pdo_mysql mbstring xml

# 3. Download and extract ATutor 2.2.4
RUN curl -L https://master.dl.sourceforge.net/project/atutor/atutor_2_2_4/ATutor%202.2.4%20Released.tar.gz?viasf=1 -o /tmp/atutor.tar.gz \
    && tar -xzf /tmp/atutor.tar.gz -C /var/www/html/ --strip-components=1 \
    && rm /tmp/atutor.tar.gz

# 4. Silent mode & ATutor compatibility fixes
RUN echo "error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_DEPRECATED & ~E_STRICT" > /usr/local/etc/php/conf.d/atutor-error-reporting.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/atutor-error-reporting.ini \
    && echo "short_open_tag = On" >> /usr/local/etc/php/conf.d/atutor-error-reporting.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/atutor-error-reporting.ini

# --- FIX 1: Disable UTF8 check in installer ---
RUN sed -i "s/\$errors\[\] = 'Database <b>'.\$db_name.'<\/b> is not in UTF8/\/\/ UTF8 check disabled/g" /var/www/html/include/install/install.inc.php

# --- FIX 2: Plug & Play Permissions ---
RUN touch /var/www/html/include/config.inc.php \
    && chown -R www-data:www-data /var/www/html/ \
    && chmod -R 775 /var/www/html/ \
    && chmod 777 /var/www/html/include \
    && chmod 666 /var/www/html/include/config.inc.php

# --- FIX 3: Reliable Debug Toggle ---
RUN sed -i "s/if (defined('AT_DEVEL') && AT_DEVEL) {/if (defined('AT_DEBUG') \&\& AT_DEBUG) {/g" /var/www/html/include/footer.inc.php

WORKDIR /var/www/html
VOLUME /var/www/html/content
EXPOSE 80
CMD ["apache2-foreground"]
