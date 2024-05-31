#!/bin/bash

# Check if all parameters are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <source_path> <destination_path> <destination_user> <destination_ip>"
    exit 1
fi

source_path=$1
destination_path=$2
destination_user=$3
destination_ip=$4

# Use rsync to transfer the source path to the destination path
rsync -avz -e "ssh" --include="*/" --include="*.*" --exclude="*" "$source_path" "$destination_user@$destination_ip:$destination_path"
