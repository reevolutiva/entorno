#!/bin/bash

# Get the path to scan from the environment variable
path_to_scan=$(printenv PATH_TO_SCAN)

# List all directories inside the specified path
find $path_to_scan -maxdepth 1 -mindepth 1 -type d
