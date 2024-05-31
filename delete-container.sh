#!/bin/bash

# Check if a parameter is provided
if [ -z "$1" ]; then
    echo "Please provide the name of the application as a parameter."
    exit 1
fi

# Get the name of the application from the parameter
app_name=$1

# Run docker ps to list all containers
containers=$(docker ps --format "{{.Names}}")

# Check if the container with the given name exists
if echo "$containers" | grep -q ".*$app_name.*"; then
    echo "Container with name containing $app_name exists."
else
    echo "Container with name containing $app_name does not exist."
fi
