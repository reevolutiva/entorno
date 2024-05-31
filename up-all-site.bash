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
        echo "Directory: $dir"
        domain=$(grep -E '^DEMYX_APP_DOMAIN=' "$dir/.env" | cut -d '=' -f2-)
        app_id=$(grep -E '^DEMYX_APP_ID=' "$dir/.env" | cut -d '=' -f2-)
        app_container=$(grep -E '^DEMYX_APP_CONTAINER=' "$dir/.env" | cut -d '=' -f2-)
        db_name=$(grep -E '^WORDPRESS_DB_NAME=' "$dir/.env" | cut -d '=' -f2-)
        db_user=$(grep -E '^WORDPRESS_DB_USER=' "$dir/.env" | cut -d '=' -f2-)
        wp_user=$(grep -E '^WORDPRESS_USER=' "$dir/.env" | cut -d '=' -f2-)
        wp_user_password=$(grep -E '^WORDPRESS_USER_PASSWORD=' "$dir/.env" | cut -d '=' -f2-)
        if [ -n "$domain" ]; then
            echo "DEMYX_APP_DOMAIN: $domain"
        fi
        if [ -n "$app_id" ]; then
            echo "DEMYX_APP_ID: $app_id"
        fi
        if [ -n "$app_container" ]; then
            echo "DEMYX_APP_CONTAINER: $app_container"
        fi
        if [ -n "$db_name" ]; then
            echo "WORDPRESS_DB_NAME: $db_name"
        fi
        if [ -n "$db_user" ]; then
            echo "WORDPRESS_DB_USER: $db_user"
        fi
        if [ -n "$wp_user" ]; then
            echo "WORDPRESS_USER: $wp_user"
        fi
        if [ -n "$wp_user_password" ]; then
            echo "WORDPRESS_USER_PASSWORD: $wp_user_password"
        fi
    fi
done
