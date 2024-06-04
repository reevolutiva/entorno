#!/bin/bash

# Prompt the user for the WordPress site path
# read -p "Enter the path to the WordPress site: " WORDPRESS_SITE_PATH
# read -p "Enter the mysql db_name: " MYSQL_DATABASE
# read -p "Enter remote user: " REMOTE_USER
# read -p "Enter remote host: " REMOTE_HOST
# read -p "Enter remote path: " REMOTE_PATH
echo "uso: ./transfer.sh CONFIG_PATH WORDPRESS_SITE_PATH MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH"

# Use command line arguments instead of prompts
CONFIG_PATH=$1
WORDPRESS_SITE_PATH=$2
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_DATABASE=$3
REMOTE_USER=$4
REMOTE_HOST=$5
REMOTE_PATH=$6

# Load variables from .env file if it exists
if [ -f "$CONFIG_PATH/.env" ]; then
    export $(grep -v '^#' $CONFIG_PATH/.env | xargs)
fi


if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "MARIADB_ROOT_PASSWORD is not defined correctly"
fi
if [ -z "$DEMYX_APP_DOMAIN" ]; then
    echo "DEMYX_APP_DOMAIN is not defined correctly"
fi
if [ -z "$DEMYX_APP_CONTAINER" ]; then
    echo "DEMYX_APP_CONTAINER is not defined correctly"
fi
if [ -z "$DEMYX_APP_DOMAIN" ]; then
    echo "DEMYX_APP_DOMAIN is not defined correctly"
fi

# Check if the variables exist and print them
if [ -n "$MARIADB_ROOT_PASSWORD" ]; then
    echo "MARIADB_ROOT_PASSWORD: $MARIADB_ROOT_PASSWORD"
fi
if [ -n "$DEMYX_APP_DOMAIN" ]; then
    echo "DEMYX_APP_DOMAIN: $DEMYX_APP_DOMAIN"
fi
if [ -n "$DEMYX_APP_CONTAINER" ]; then
    echo "DEMYX_APP_CONTAINER: $DEMYX_APP_CONTAINER"
fi
if [ -n "$DEMYX_APP_DOMAIN" ]; then
    echo "DEMYX_APP_DOMAIN: $DEMYX_APP_DOMAIN"
fi

# Validate the existence of required variables
if [ -z "$CONFIG_PATH" ] || [ -z "$WORDPRESS_SITE_PATH" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_PATH" ]; then
    echo "One or more required variables are missing. Exiting..."
    exit 1
fi

# Extract the WordPress site from the server origin
cd $WORDPRESS_SITE_PATH
#zip -r $WORDPRESS_SITE_PATH.zip .

if [ -d "$WORDPRESS_SITE_PATH/web" ]; then

    echo "site"
    echo $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.sql

    # WordPress site is Bedrock
    cd $WORDPRESS_SITE_PATH/web
    zip -r $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.zip .

    # Extract the BDD from the WordPress site
    mysqldump -u$MYSQL_USER -p$MARIADB_ROOT_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.sql

    #Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

    rsync -a -e ssh $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi

if [ -d "$WORDPRESS_SITE_PATH/web" ]; then
    cd $WORDPRESS_SITE_PATH/wp-content/
    # WordPress site is Vanilla
    zip -r $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.zip .

    echo $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.sql
    # Extract the BDD from the WordPress site
    mysqldump -u$MYSQL_USER -p$MARIADB_ROOT_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH$DEMYX_APP_DOMAIN.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi
