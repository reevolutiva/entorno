FROM demyx/openlitespeed:bedrock

WORKDIR /demyx/

# Annado variable de entorno DOMAIN_CURRENT_SITE
RUN cat .env + "\r DOMAIN_CURRENT_SITE='YOURSITE.com' " > .env

WORKDIR /demyx/config/

# Annado este codigo al aplication.php

# /**
#  * Multisite
#  */
# Config::define('WP_ALLOW_MULTISITE', true);
# Config::define('MULTISITE', true);
# Config::define('SUBDOMAIN_INSTALL', false);
# Config::define('DOMAIN_CURRENT_SITE', env('DOMAIN_CURRENT_SITE'));
# Config::define('PATH_CURRENT_SITE', env('PATH_CURRENT_SITE') ?: '/');
# Config::define('SITE_ID_CURRENT_SITE', env('SITE_ID_CURRENT_SITE') ?: 1);
# Config::define('BLOG_ID_CURRENT_SITE', env('BLOG_ID_CURRENT_SITE') ?: 1);"


# Instalo el plugin url fixer
WORKDIR /demyx/web/app/mu-plugins/
RUN composer require roots/multisite-url-fixer