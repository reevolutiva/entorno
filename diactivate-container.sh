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

# Check if docker-compose.yml exists in the provided src path
if [ -f "$src/docker-compose.yml" ]; then
    # Change to the directory containing docker-compose.yml
    cd "$src" || exit 1
    echo "Fue encontrado un docker compose en $src..."
    echo "Desactivando contenedor en $src..."
    # Execute docker compose down
    docker compose down
    echo "Contenedor desactivado"

    # Ask the user if they want to delete the volumes
    read -p "¿Desea eliminar los volúmenes? (y/n): " response
    if [ "$response" = "y" ]; then
        # Remove the directory containing docker-compose.yml
        rm -rf "$src"
        echo "Carpeta eliminada"

        # Check if --src-vol parameter is provided and user wants to delete it
        if [ -n "$src_vol" ] && [ "$response" = "y" ]; then
            rm -rf "$src_vol"
            echo "Carpeta en el segundo parámetro eliminada"
        fi
    fi
else
    echo "Error: No docker-compose.yml found in the provided path: $src"
    exit 1
fi
