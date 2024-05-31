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
        # Read the .env file and search for DEMYX_APP_DOMAIN
        domain=$(grep -E '^DEMYX_APP_DOMAIN=' "$dir/.env" | cut -d '=' -f2-)
        if [ -n "$domain" ]; then
            echo "DEMYX_APP_DOMAIN: $domain"
        fi
    fi
done
