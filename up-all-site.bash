#!/bin/bash

# Get the path to scan from the environment variable or a flag
if [ "$1" != "" ]; then
    path_to_scan=$1
else
    path_to_scan=$(printenv PATH_TO_SCAN)
fi

# List all directories inside the specified path
find $path_to_scan -maxdepth 1 -mindepth 1 -type d
