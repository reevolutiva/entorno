#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--app)
        my_app="$2"
        shift
        shift
        ;;
        -d|--domain)
        your_domain="$2"
        shift
        shift
        ;;
        -e|--email)
        your_email="$2"
        shift
        shift
        ;;
        -p|--db-password)
        your_db_password="$2"
        shift
        shift
        ;;
        -u|--db-user)
        your_db_user="$2"
        shift
        shift
        ;;
        -w|--wp-user)
        your_wp_user="$2"
        shift
        shift
        ;;
        -wp|--wp-password)
        your_wp_password="$2"
        shift
        shift
        ;;
        -n|--new-db-name)
        new_db_name="$2"
        shift
        shift
        ;;
        -b|--is-bedrock)
        is_bedrock="$2"
        shift
        shift
        ;;
        -h|--help)
        echo "Usage: reciber.sh [OPTIONS]"
        echo "Options:"
        echo "  -a, --app           Specify the app name"
        echo "  -d, --domain        Specify the domain"
        echo "  -e, --email         Specify the email"
        echo "  -p, --db-password   Specify the database password"
        echo "  -u, --db-user       Specify the database user"
        echo "  -w, --wp-user       Specify the WordPress user"
        echo "  -wp, --wp-password  Specify the WordPress password"
        echo "  -n, --new-db-name   Specify the new database name"
        echo "  -b, --is-bedrock    Specify if it is a Bedrock app (true/false)"
        echo "  -h, --help          Show help"
        exit 0
        ;;
        *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Check if all required parameters are provided
if [[ -z $my_app || -z $your_domain || -z $your_email || -z $your_db_password || -z $your_db_user || -z $your_wp_user || -z $your_wp_password || -z $new_db_name ]]; then
    echo "Missing required parameters"
    exit 1
fi

# mkdir /home/hosting/reevolutiva-net/$your_domain
chown -R 1000:1000 /home/hosting/reevolutiva-net/$your_domain 

# Intanciaar un contenedor docker wp funcional
# Clonar la plantilla desde entorno/templates/.env.temp a ./.env
cp templates/.env.temp /home/hosting/reevolutiva-net/$your_domain/.env

# Clonar la plantilla desde temp-docker-compose.yml a ./docker-compose.yml

if [[ $is_bedrock == "true" ]]; then
    echo "Es bedrock"
   cp templates/temp-docker-compose-bedrock.yml /home/hosting/reevolutiva-net/$your_domain/docker-compose.yml
else
    echo "No Es bedrock"
   cp templates/temp-docker-compose.yml /home/hosting/reevolutiva-net/$your_domain/docker-compose.yml
fi

# Reemplazar en el .env y en la plantilla de docker-compose
sed -i "s/<my_app>/$my_app/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<my_app>/$my_app/g" /home/hosting/reevolutiva-net/$your_domain/docker-compose.yml
sed -i "s/<my_domain>/$your_domain/g" /home/hosting/reevolutiva-net/$your_domain/docker-compose.yml
sed -i "s/<my_domain>/$your_domain/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/info@<my_domain>/$your_email/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<bd_password>/$your_db_password/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<user_bdd>/$your_db_user/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<user_wp>/$your_wp_user/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<your_wp_password>/$your_wp_password/g" /home/hosting/reevolutiva-net/$your_domain/.env
sed -i "s/<your_db_name>/$new_db_name/g" /home/hosting/reevolutiva-net/$your_domain/.env

# Crear una carpeta con el nombre del sitio para almacenar sus volumnes
mkdir /home/hosting/$your_domain/wp
mkdir /home/hosting/$your_domain/db
mkdir /home/hosting/$your_domain/log

# # Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 1000
chown -R 1000:1000 /home/hosting/$your_domain/wp 
chown -R 1000:1000 /home/hosting/$your_domain/db 
chown -R 1000:1000 /home/hosting/$your_domain/log

# Entrar a la carpeta del docker-compose
cd /home/hosting/reevolutiva-net/$your_domain

# Levantamos el docker-compose.yml
docker compose up -d

# Nos movemos a los volumenes de la carpeta wp
cd /home/hosting/$your_domain

mkdir temp/

mv $your_domain.zip /home/hosting/kban.cl/temp/
mv $your_domain.sql /home/hosting/$your_domain/db

cd temp/

unzip $your_domain.zip

cd ..

# Eliminamos el contenido actual de app
rm -r /home/hosting/$your_domain/wp/web/app

#Movemos el contenido de temp a app
mv /home/hosting/$your_domain/temp/app /home/hosting/$your_domain/wp/web/

# Cambiamos los permisos de todos los ficheros dentro de la carpeta wp
chmod -R 755 /home/hosting/$your_domain/wp/
chmod -R 755 /home/hosting/$your_domain/db/


# Entramos a la terminal del contenedor mysql.
# Entramos a mysql.

# Remueve de esta variable el punto y devuelve un string nuevo $your_domain
new_domain="${your_domain//./}"

# $new_domain-wp_$my_app-1
# $new_domain-db_$my_app-1

docker exec $new_domain-db_$my_app-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju  -e "CREATE DATABASE IF NOT EXISTS $new_db_name;"
docker exec $new_domain-db_$my_app-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju $new_db_name -e "SOURCE $your_domain.sql;"
docker exec $new_domain-db_$my_app-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju -e "GRANT ALL PRIVILEGES ON $new_db_name.* TO '$your_wp_user';"


# Cambiamos el nombre de la BDD en wp-config.php
# Si es bedrock cambia el .env

to_erace=$my_app'_dev'

if [[ $is_bedrock == "true" ]]; then
   sed -i "s/DB_NAME='$to_erace'/DB_NAME='$new_db_name'/g" /home/hosting/$your_domain/wp/.env
   echo "Es bedrock"
else
   sed -i "s/define( 'DB_NAME', '$to_erace' );/define( 'DB_NAME', '$new_db_name' );/g" /home/hosting/$your_domain/wp-config.php
   echo "No es bedrock"
fi



