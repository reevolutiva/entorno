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

mkdir $my_app

# Intanciaar un contenedor docker wp funcional
# Clonar la plantilla desde entorno/templates/.env.temp a ./.env
cp templates/.env.temp ./$my_app/.env

# Clonar la plantilla desde temp-docker-compose.yml a ./docker-compose.yml
cp templates/temp-docker-compose.yml ./$my_app/docker-compose.yml

# Reemplazar en el .env y en la plantilla de docker-compose
sed -i "s/<my_app>/$my_app/g" ./$my_app/.env
sed -i "s/<my_app>/$my_app/g" ./$my_app/docker-compose.yml
sed -i "s/<my_domain>/$your_domain/g" ./$my_app/docker-compose.yml
sed -i "s/<my_domain>/$your_domain/g" ./$my_app/.env
sed -i "s/info@<my_domain>/$your_email/g" ./$my_app/.env
sed -i "s/<bd_password>/$your_db_password/g" ./$my_app/.env
sed -i "s/<user_bdd>/$your_db_user/g" ./$my_app/.env
sed -i "s/<user_wp>/$your_wp_user/g" ./$my_app/.env
sed -i "s/<your_wp_password>/$your_wp_password/g" ./$my_app/.env
sed -i "s/<your_db_name>/$new_db_name/g" ./$my_app/.env

# Crear una carpeta con el nombre del sitio para almacenar sus volumnes
mkdir $my_app/wp
mkdir $my_app/db
mkdir $my_app/log

# Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 1000
chown -R 1000:1000 $my_app/wp 
chown -R 1000:1000 $my_app/db 
chown -R 1000:1000 $my_app/log

# Levantamos el docker-compose.yml
docker-compose up -d

# Copiamos el archivo .zip a la carpeta wp
# cd wp
# unzip <your_app_name>.zip
# cd ..

# # Cambiamos los permisos de todos los ficheros dentro de la carpeta wp
# chmod -R 755 wp/<your_app_name>

# # Entramos a la terminal del contenedor mysql.
# # Entramos a mysql.
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "CREATE DATABASE IF NOT EXISTS <your_db_name>;"
# docker-compose exec db_<your_app_name> mysql <your_db_name>.sql
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "GRANT ALL PRIVILEGES ON <your_db_name>. * TO '<your_db_user>'@'localhost' IDENTIFIED BY '<your_db_password>';"
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "SET GLOBAL general_log = 'ON';"
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "SET GLOBAL log_output = 'FILE';"
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "SET GLOBAL log_file = '/var/log/mysql/<your_db_name>.log';"
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "SET GLOBAL log_slow_verbosity = 'QUERY_PLANS';"
# docker-compose exec db_<your_app_name> mysql -u <your_db_user> -p <your_db_password> -e "FLUSH LOGS;"

# # Cambiamos el nombre de la BDD en wp-config.php
# sed -i "s/<your_db_name>/$new_db_name/g" wp/<your_app_name>/wp-config.php
