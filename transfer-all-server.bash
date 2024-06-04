#!/bin/bash

# Check if all flags are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 -s <source_path> -d <destination_path> -u <destination_user> -i <destination_ip> -f <json_file>"
    echo "  -s, --source-path    Source path to transfer"
    echo "  -d, --destination-path Destination path to transfer to"
    echo "  -u, --destination-user Destination user"
    echo "  -i, --destination-ip   Destination IP address"
    echo "  -f, --json-file      JSON file to read"
    exit 1
fi

while getopts ":s:d:u:i:f:" opt; do
  case $opt in
    s) SOURCE_PATH="$OPTARG" ;;
    d) DESTINATION_PATH="$OPTARG" ;;
    u) DESTINATION_USER="$OPTARG" ;;
    i) DESTINATION_IP="$OPTARG" ;;
    f) JSON_FILE="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done

# Read JSON file content
if [ -f "$JSON_FILE" ]; then
    JSON_CONTENT=$(cat "$JSON_FILE")
    echo "JSON file content:"
    echo "$JSON_CONTENT"
else
    echo "JSON file not found: $JSON_FILE"
    exit 1
fi

# Parse JSON array
JSON_ARRAY=($(echo "$JSON_CONTENT" | jq -r '.[].item'))

# Loop through the array and execute transfer.sh with each item
for ITEM in "${JSON_ARRAY[@]}"; do
    echo "Executing transfer.sh with item: $ITEM"
    bash transfer.sh "$ITEM"
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
