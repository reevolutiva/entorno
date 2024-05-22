#!/bin/bash

# Ask user for input for placeholders
echo "Enter your app name:"
read my_app
echo "Enter your domain name:"
read your_domain
echo "Enter your email:"
read your_email
echo "Enter your DB password:"
read your_db_password
echo "Enter your DB user:"
read your_db_user
echo "Enter your WP user:"
read your_wp_user
echo "Enter your WP password:"
read your_wp_password
echo "Enter your new DB name:"
read new_db_name

# Check if the files exist before copying
if [ ! -f env/templates/.env.temp ]; then
    echo "Error: .env.temp file not found."
    exit 1
fi

if [ ! -f env/templates/temp-docker-compose.yml ]; then
    echo "Error: temp-docker-compose.yml file not found."
    exit 1
fi

# Clone the templates to the current directory
cp env/templates/.env.temp ./.env
cp env/templates/temp-docker-compose.yml ./docker-compose.yml

# Replace placeholders in the .env and docker-compose.yml files using a more specific regular expression
sed -i "/<my_app>/s/<my_app>/$my_app/g" .env
sed -i "/<my_domain_app>/s/<my_domain_app>/$your_domain/g" .env
sed -i "/info@<my_domain_app>/s/info@<my_domain_app>/$your_email/g" .env
sed -i "/<bd_password>/s/<bd_password>/$your_db_password/g" .env
sed -i "/<user_bdd>/s/<user_bdd>/$your_db_user/g" .env
sed -i "/<user_wp>/s/<user_wp>/$your_wp_user/g" .env
sed -i "/<your_wp_password>/s/<your_wp_password>/$your_wp_password/g" .env
sed -i "/<your_db_name>/s/<your_db_name>/$new_db_name/g" .env

# Create directories if they don't exist
if [ ! -d wp ]; then
    mkdir wp
fi


if [ ! -d db ]; then
    mkdir db
fi

if [ ! -d log ]; then
    mkdir log
fi

# Change the ownership of the directories and all files inside them
chown -R 1000:1000 wp db log

# Check if the containers are already running before starting them
if [ $(docker ps -q -f name=db_$my_app) ]; then
    echo "Error: db container $my_app is already running."
    exit 1
fi

if [continues here...]
