#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --src) src="$2"; shift ;;
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
    # Execute docker compose down
    docker compose down
else
    echo "Error: No docker-compose.yml found in the provided path: $src"
    exit 1
fi
