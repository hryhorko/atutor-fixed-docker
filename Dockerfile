# Use PHP 7.1 with Apache as the base image for compatibility with ATutor 2.2.4
FROM php:7.1-apache

# 1. Fix for EOL (End of Life) Debian repositories
# Redirects apt-get to archive.debian.org to allow package installation
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

# 2. Install system dependencies and PHP extensions
# Required for image processing (GD), database connection (mysqli), and file downloads (curl)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli

# 3. Download and extract ATutor source code
# Fetches the stable 2.2.4 release and unpacks it directly to the web root
RUN curl -L  https://master.dl.sourceforge.net/project/atutor/atutor_2_2_4/ATutor%202.2.4%20Released.tar.gz?viasf=1 -o /tmp/atutor.tar.gz \
    && tar -xzf /tmp/atutor.tar.gz -C /var/www/html/ --strip-components=1 \
    && rm /tmp/atutor.tar.gz

# 4. Prepare "Plug & Play" configuration file
# Pre-creates the config file and sets correct permissions so the web installer can write to it automatically
RUN touch /var/www/html/include/config.inc.php \
    && chown -R www-data:www-data /var/www/html/ \
    && chmod 664 /var/www/html/include/config.inc.php

# 5. Apply Debug Mode Fix
# Injects a check into vital_funcs.inc.php to respect the AT_DEBUG constant from config.inc.php
RUN sed -i '/function debug($var, $title="") {/a \    if (!defined("AT_DEBUG") || !AT_DEBUG) return;' /var/www/html/include/lib/vital_funcs.inc.php

# Set working directory
WORKDIR /var/www/html

# Expose port 80 for web traffic
EXPOSE 80

# Default Apache command
CMD ["apache2-foreground"]
