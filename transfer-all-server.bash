#!/bin/bash

# Check if all flags are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 -s <source_path> -d <destination_path> -u <destination_user> -i <destination_ip>"
    exit 1
fi

while getopts ":s:d:u:i:" opt; do
  case $opt in
    s) SOURCE_PATH="$OPTARG" ;;
    d) DESTINATION_PATH="$OPTARG" ;;
    u) DESTINATION_USER="$OPTARG" ;;
    i) DESTINATION_IP="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done

# Print message before transferring
echo "Transferring..."

# Use rsync to transfer the source path to the destination path
rsync -avz -e "ssh" --include="*/" --include="*.*" --exclude="*" "$SOURCE_PATH" "$DESTINATION_USER@$DESTINATION_IP:$DESTINATION_PATH"

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Transfer successful"
else
    echo "Transfer failed"
fi
