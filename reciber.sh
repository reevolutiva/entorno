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

mkdir /home/hosting/reevolutiva-net/$your_domain
chown -R 1000:1000 /home/hosting/reevolutiva-net/$your_domain 

# Intanciaar un contenedor docker wp funcional
# Clonar la plantilla desde entorno/templates/.env.temp a ./.env
cp templates/.env.temp /home/hosting/reevolutiva-net/$your_domain/.env

# Clonar la plantilla desde temp-docker-compose.yml a ./docker-compose.yml
cp templates/temp-docker-compose.yml /home/hosting/reevolutiva-net/$your_domain/docker-compose.yml

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

# Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 1000
chown -R 1000:1000 /home/hosting/$your_domain/wp 
chown -R 1000:1000 /home/hosting/$your_domain/db 
chown -R 1000:1000 /home/hosting/$your_domain/log

# Levantamos el docker-compose.yml
#docker-compose up -d

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
