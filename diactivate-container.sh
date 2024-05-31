#!/bin/bash

# Check if the flag is provided
if [ "$1" == "-src" ]; then
    # Get the path to docker-compose.yml
    DOCKER_COMPOSE_PATH=$(find . -name "docker-compose.yml" -print -quit)

    # Check if the file exists
    if [ -f "$DOCKER_COMPOSE_PATH" ]; then
        # Execute docker compose down
        docker compose -f "$DOCKER_COMPOSE_PATH" down
    else
        echo "docker-compose.yml not found"
    fi
fi
