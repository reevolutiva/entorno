#!/bin/bash

# Ask user inputs
read -p "Enter your app name: " your_app_name
read -p "Enter your domain: " your_domain
read -p "Enter your email: " your_email
read -p "Enter your DB password: " your_db_password
read -p "Enter your DB user: " your_db_user
read -p "Enter your WP user: " your_wp_user
read -p "Enter your WP password: " your_wp_password
read -p "Enter your DB name: " your_db_name
read -p "Enter new DB name: " new_db_name

# Instanciaar un contenedor docker wp funcional
# Clonar la plantilla desde entorno/templates/.env.temp a ./.env
cp env/templates/.env.temp ./.env

# Reemplazar en el .env y en la plantilla de docker-compose
sed -i "s/<your_app_name>/${your_app_name}/g" .env
sed -i "s/<your_domain>/${your_domain}/g" .env
sed -i "s/<your_email>/${your_email}/g" .env
sed -i "s/<your_db_password>/${your_db_password}/g" .env
sed -i "s/<your_db_user>/${your_db_user}/g" .env
sed -i "s/<your_wp_user>/${your_wp_user}/g" .env
sed -i "s/<your_wp_password>/${your_wp_password}/g" .env
sed -i "s/<your_db_name>/${your_db_name}/g" .env
sed -i "s/<new_db_name>/${new_db_name}/g" .env

# Rest of the script remains the same
