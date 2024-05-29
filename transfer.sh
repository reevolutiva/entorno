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
echo "uso: ./transfer.sh WORDPRESS_SITE WORDPRESS_SITE_PATH MYSQL_HOST MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH"

# Use command line arguments instead of prompts
WORDPRESS_SITE=$1
WORDPRESS_SITE_PATH=$2
MYSQL_HOST=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$6
MYSQL_DATABASE=$7
REMOTE_USER=$8
REMOTE_HOST=$9
REMOTE_PATH=$10

# Extract the WordPress site from the server origin
cd $WORDPRESS_SITE_PATH
#zip -r $WORDPRESS_SITE_PATH.zip .

if [ -d "$WORDPRESS_SITE_PATH/web" ]; then

    echo "site"
    echo $WORDPRESS_SITE_PATH . $WORDPRESS_SITE.sql

    # WordPress site is Bedrock
    cd $WORDPRESS_SITE_PATH/web
    #zip -r $WORDPRESS_SITE_PATH.zip .

    # Extract the BDD from the WordPress site
    #mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH.sql

    # Transfer the .zip and .sql files to the destination server
    #rsync -a -e ssh $WORDPRESS_SITE_PATH.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

    #rsync -a -e ssh $WORDPRESS_SITE_PATH.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

else
    # WordPress site is Vanilla
    zip -r $WORDPRESS_SITE_PATH.zip ./wp-content

    # Extract the BDD from the WordPress site
    mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $WORDPRESS_SITE_PATH.sql

    # Transfer the .zip and .sql files to the destination server
    rsync -a -e ssh $WORDPRESS_SITE_PATH.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
    rsync -a -e ssh $WORDPRESS_SITE_PATH.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi
