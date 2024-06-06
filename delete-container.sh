#!/bin/bash

# Check if a parameter is provided
# if [ -z "$1" ]; then
#     echo "Please provide the name of the application as a parameter."
#     exit 1
# fi

# # Get the name of the application from the parameter
# app_name=$1

# # Run docker ps to list all containers
# containers=$(docker ps --format "{{.Names}}")

# # List all containers with names containing the given app_name
# echo "Containers with names containing $app_name:"
# echo "$containers" | grep ".*$app_name.*"

#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --src) src="$2"; shift ;;
        --src-vol) src_vol="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$src" ]; then
    echo "Error: --src parameter is required."
    exit 1
fi

# Remove the directory containing docker-compose.yml
rm -rf "$src"
echo "Carpeta eliminada $src"

# Check if --src-vol parameter is provided and user wants to delete it
if [ -n "$src_vol" ] && [ "$response" = "y" ]; then
    rm -rf "$src_vol"
    echo "Carpeta eliminada $src_vol"
fi

