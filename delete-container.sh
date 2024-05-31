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

# List all containers with names containing the given app_name
echo "Containers with names containing $app_name:"
echo "$containers" | grep ".*$app_name.*"
