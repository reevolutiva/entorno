#!/bin/bash

# Get the path to scan from the "--src" flag or default to the environment variable
if [ "$1" != "" ]; then
    if [ "$1" == "--src" ]; then
        path_to_scan=$2
    else
        path_to_scan=$(printenv PATH_TO_SCAN)
    fi
else
    path_to_scan=$(printenv PATH_TO_SCAN)
fi

# List all directories inside the specified path and check for .env file
find $path_to_scan -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
    if [ -f "$dir/.env" ]; then
        # Read the .env file and search for DEMYX_APP_DOMAIN, DEMYX_APP_ID, DEMYX_APP_CONTAINER, WORDPRESS_DB_NAME, WORDPRESS_DB_USER, WORDPRESS_USER, WORDPRESS_USER_PASSWORD
        echo " "
        echo "Directory: $dir"
        echo " "
        domain=$(grep -E '^DEMYX_APP_DOMAIN=' "$dir/.env" | cut -d '=' -f2-)
        app_id=$(grep -E '^DEMYX_APP_ID=' "$dir/.env" | cut -d '=' -f2-)
        app_container=$(grep -E '^DEMYX_APP_CONTAINER=' "$dir/.env" | cut -d '=' -f2-)
        db_name=$(grep -E '^WORDPRESS_DB_NAME=' "$dir/.env" | cut -d '=' -f2-)
        db_user=$(grep -E '^WORDPRESS_DB_USER=' "$dir/.env" | cut -d '=' -f2-)
        user=$(grep -E '^WORDPRESS_USER=' "$dir/.env" | cut -d '=' -f2-)
        user_password=$(grep -E '^WORDPRESS_USER_PASSWORD=' "$dir/.env" | cut -d '=' -f2-)

        # Print the found variables
        echo "DEMYX_APP_DOMAIN: $domain"
        echo "DEMYX_APP_ID: $app_id"
        echo "DEMYX_APP_CONTAINER: $app_container"
        echo "WORDPRESS_DB_NAME: $db_name"
        echo "WORDPRESS_DB_USER: $db_user"
        echo "WORDPRESS_USER: $user"
        echo "WORDPRESS_USER_PASSWORD: $user_password"

        # Check if docker-compose.yml exists in the directory
        if [ -f "$dir/docker-compose.yml" ]; then
            # Change to the directory and run docker compose up -d
            cd "$dir" || exit
            echo " "
            echo "- levantando contenedor '$domain'"
            echo " "
            docker compose up -d
            echo "- contenedor '$domain' levantado correctamente"
            echo " "
        fi
    fi
done
