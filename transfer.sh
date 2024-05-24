#!/bin/bash

# Prompt the user for the WordPress site path
# read -p "Enter the path to the WordPress site: " WORDPRESS_SITE_PATH
# read -p "Enter the mysql host: " MYSQL_HOST
# read -p "Enter the mysql user: " MYSQL_USER
# read -p "Enter the mysql pasword: " MYSQL_PASSWORD
# read -p "Enter the mysql db_name: " MYSQL_DATABASE
# read -p "Enter remote user: " REMOTE_USER
# read -p "Enter remote host: " REMOTE_HOST
# read -p "Enter remote path: " REMOTE_PATH

# Use command line arguments instead of prompts
WORDPRESS_SITE_PATH=$1
MYSQL_HOST=$2
MYSQL_USER=$3
MYSQL_PASSWORD=$4
MYSQL_DATABASE=$5
REMOTE_USER=$6
REMOTE_HOST=$7
REMOTE_PATH=$8

# Extract the WordPress site from the server origin
cd $WORDPRESS_SITE_PATH
#zip -r $WORDPRESS_SITE_PATH.zip .

if [ -d "$WORDPRESS_SITE_PATH/web" ]; then
    # WordPress site is Bedrock
    cd $WORDPRESS_SITE_PATH/web
    zip -r $WORDPRESS_SITE_PATH.zip .

    # Extract the BDD from the WordPress site
    mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

    rsync -a -e ssh $WORDPRESS_SITE_PATH.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

else
    # WordPress site is Vanilla
    zip -r $WORDPRESS_SITE_PATH.zip ./wp-content

    # Extract the BDD from the WordPress site
    mysqldump -u $MYSQL_USER -p $MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
    rsync -a -e ssh $WORDPRESS_SITE_PATH.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi
