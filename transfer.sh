#!/bin/bash

# Prompt the user for the WordPress site path
# read -p "Enter the path to the WordPress site: " WORDPRESS_SITE
# read -p "Enter the path to the WordPress site: " WORDPRESS_SITE_PATH
# read -p "Enter the mysql host: " MYSQL_HOST
# read -p "Enter the mysql user: " MYSQL_USER
# read -p "Enter the mysql pasword: " MYSQL_PASSWORD
# read -p "Enter the mysql db_name: " MYSQL_DATABASE
# read -p "Enter remote user: " REMOTE_USER
# read -p "Enter remote host: " REMOTE_HOST
# read -p "Enter remote path: " REMOTE_PATH
# read -p "Enter demyx (bool or string): " DEMYX
echo "uso: ./transfer.sh WORDPRESS_SITE WORDPRESS_SITE_PATH MYSQL_HOST MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH DEMYX"

# Use command line arguments instead of prompts
WORDPRESS_SITE=$1
WORDPRESS_SITE_PATH=$2
MYSQL_HOST=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$5
MYSQL_DATABASE=$6
REMOTE_USER=$7
REMOTE_HOST=$8
REMOTE_PATH=$9
DEMYX=${10}

# Check if DEMYX is not false and search for the specified folders
if [[ "$DEMYX" != "false" ]]; then
    DEMYX_WP_FOLDER="${WORDPRESS_SITE_PATH}/${DEMYX}_wp"
    DEMYX_DB_FOLDER="${WORDPRESS_SITE_PATH}/${DEMYX}_db"

    if [ -d "$DEMYX_WP_FOLDER" ]; then
        cd $DEMYX_WP_FOLDER
        zip -r $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip .
    else
        echo "{$DEMYX}_wp folder not found."
    fi

    if [ -d "$DEMYX_DB_FOLDER" ]; then
        cd $DEMYX_DB_FOLDER
        zip -r $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip .
    else
        echo "{$DEMYX}_db folder not found."
    fi
fi

# Extract the WordPress site from the server origin
cd $WORDPRESS_SITE_PATH
#zip -r $WORDPRESS_SITE_PATH.zip .

if [ -d "$WORDPRESS_SITE_PATH/web" ]; then

    #echo "site"
    #echo $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql

    # WordPress site is Bedrock
    cd $WORDPRESS_SITE_PATH/web
    zip -r $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip .

    # Extract the BDD from the WordPress site
    mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

else
    cd $WORDPRESS_SITE_PATH/wp-content/
    # WordPress site is Vanilla
    zip -r $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip .

    echo $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql
    # Extract the BDD from the WordPress site
    mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
    rsync -a -e ssh $WORDPRESS_SITE_PATH$WORDPRESS_SITE.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi
