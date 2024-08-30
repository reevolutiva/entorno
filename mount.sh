# Use command line arguments instead of prompts
#!/bin/bash

# Define default values for the parameters
YOUR_DOMAIN=$1
SRC_VOL=$2

Check if --domain parameter is provided
if [ -z "$YOUR_DOMAIN" ]; then
    echo "Error: <domain> parameter is required."
    exit 1
fi

# Check if --src parameter is provided
if [ -z "$SRC_VOL" ]; then
    echo "Error: <src-vol> parameter is required."
    exit 1
fi

cd "$SRC_VOL"
docker compose up -d
echo "Contenedor levantado correctamente"