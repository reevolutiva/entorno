#!/bin/bash

# Use command line arguments instead of prompts
#!/bin/bash

# Define default values for the parameters
YOUR_DOMAIN=""
MY_APP=""
YOUR_EMAIL=""
YOUR_DB_PASSWORD=""
YOUR_DB_USER=""
YOUR_WP_USER=""
YOUR_WP_PASSWORD=""
NEW_DB_NAME=""
REMOTE_PATH=""
IS_BEDROCK="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--domain)
            YOUR_DOMAIN="$2"
            shift
            shift
            ;;
        -a|--app)
            MY_APP="$2"
            shift
            shift
            ;;
        -e|--email)
            YOUR_EMAIL="$2"
            shift
            shift
            ;;
        -p|--db-password)
            YOUR_DB_PASSWORD="$2"
            shift
            shift
            ;;
        -u|--db-user)
            YOUR_DB_USER="$2"
            shift
            shift
            ;;
        -w|--wp-user)
            YOUR_WP_USER="$2"
            shift
            shift
            ;;
        -wp|--wp-password)
            YOUR_WP_PASSWORD="$2"
            shift
            shift
            ;;
        -n|--db-name)
            NEW_DB_NAME="$2"
            shift
            shift
            ;;
        -ib|--is-bedrock)
            IS_BEDROCK="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if all required parameters are provided
if [[ -z $YOUR_DOMAIN || -z $MY_APP || -z $YOUR_EMAIL || -z $YOUR_DB_PASSWORD || -z $YOUR_DB_USER || -z $YOUR_WP_USER || -z $YOUR_WP_PASSWORD || -z $NEW_DB_NAME ]]; then
    echo "Missing required parameters"
    echo "Usage: $0 -d|--domain <your_domain> -a|--app <my_app> -e|--email <your_email> -p|--db-password <your_db_password> -u|--db-user <your_db_user> -w|--wp-user <your_wp_user> -wp|--wp-password <your_wp_password> -n|--db-name <new_db_name> -ib|--is-bedrock <is_bedrock>"
    exit 1
fi

# Rest of the script...
mkdir /home/hosting/reevolutiva-net/$YOUR_DOMAIN
chown -R 1000:1000 /home/hosting/reevolutiva-net/$YOUR_DOMAIN 
# Intanciaar un contenedor docker wp funcional
# Clonar la plantilla desde entorno/templates/.env.temp a ./.env
cp templates/.env.temp /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
# Clonar la plantilla desde temp-docker-compose.yml a ./docker-compose.yml
if [[ $IS_BEDROCK == "true" ]]; then
    echo "Es bedrock"
   cp templates/temp-docker-compose-bedrock.yml /home/hosting/reevolutiva-net/$YOUR_DOMAIN/docker-compose.yml
else
    echo "No Es bedrock"
   cp templates/temp-docker-compose.yml /home/hosting/reevolutiva-net/$YOUR_DOMAIN/docker-compose.yml
fi
# Reemplazar en el .env y en la plantilla de docker-compose
sed -i "s/<my_app>/$MY_APP/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<my_app>/$MY_APP/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/docker-compose.yml
sed -i "s/<my_domain>/$YOUR_DOMAIN/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/docker-compose.yml
sed -i "s/<my_domain>/$YOUR_DOMAIN/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/info@<my_domain>/$YOUR_EMAIL/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<bd_password>/$YOUR_DB_PASSWORD/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<user_bdd>/$YOUR_DB_USER/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<user_wp>/$YOUR_WP_USER/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<your_wp_password>/$YOUR_WP_PASSWORD/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
sed -i "s/<your_db_name>/$NEW_DB_NAME/g" /home/hosting/reevolutiva-net/$YOUR_DOMAIN/.env
# Crear una carpeta con el nombre del sitio para almacenar sus volumnes
mkdir /home/hosting/$YOUR_DOMAIN/wp
mkdir /home/hosting/$YOUR_DOMAIN/db
mkdir /home/hosting/$YOUR_DOMAIN/log
# # Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 1000
chown -R 1000:1000 /home/hosting/$YOUR_DOMAIN/wp 
chown -R 1000:1000 /home/hosting/$YOUR_DOMAIN/db 
chown -R 1000:1000 /home/hosting/$YOUR_DOMAIN/log
# Entrar a la carpeta del docker-compose
cd /home/hosting/reevolutiva-net/$YOUR_DOMAIN
# Levantamos el docker-compose.yml
docker compose up -d
# Nos movemos a los volumenes de la carpeta wp
cd /home/hosting/$YOUR_DOMAIN
# Cambiamos los permisos de todos los ficheros dentro de la carpeta wp
chmod -R 755 /home/hosting/$YOUR_DOMAIN/wp/
chmod -R 755 /home/hosting/$YOUR_DOMAIN/db/
# Entramos a la terminal del contenedor mysql.
# Entramos a mysql.
# # Remueve de esta variable el punto y devuelve un string nuevo $YOUR_DOMAIN
NEW_DOMAIN="${YOUR_DOMAIN//./}"
# $new_domain-wp_$MY_APP-1
# $new_domain-db_$MY_APP-1
docker exec $NEW_DOMAIN-db_$MY_APP-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju  -e "CREATE DATABASE ${NEW_DB_NAME};"
docker exec $NEW_DOMAIN-db_$MY_APP-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju $NEW_DB_NAME -e "SOURCE $YOUR_DOMAIN.sql;"
docker exec $NEW_DOMAIN-db_$MY_APP-1 mysql -uroot -pIL2zdC4XPrKstbDyCGju -e "GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$YOUR_WP_USER';"
