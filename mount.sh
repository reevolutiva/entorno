# Use command line arguments instead of prompts
#!/bin/bash

# Define default values for the parameters
YOUR_DOMAIN=""
SRC_VOL=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--domain)
            YOUR_DOMAIN="$2"
            shift
            shift
            ;;
            ;;
        -sv|--src-vol)
            SRC_VOL="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if --domain parameter is provided
if [ -z "$YOUR_DOMAIN" ]; then
    echo "Error: --domain parameter is required."
    exit 1
fi

# Check if --src parameter is provided
if [ -z "$SRC" ]; then
    echo "Error: --src parameter is required."
    exit 1
fi

cd "$SRC_VOL"
docker compose up -d
echo "Contenedor levantado correctamente"