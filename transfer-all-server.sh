#!/bin/bash

#script en desarrollo

# Check if all flags are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0  <source_path>  <destination_path>  <destination_user> <destination_ip>  <json_file>"
    exit 1
fi

SOURCE_PATH=$1
DESTINATION_PATH=$2
DESTINATION_USER=$3
DESTINATION_IP=$4
JSON_FILE=$5

echo $JSON_FILE;

# Read JSON file content
if [ -f "$JSON_FILE" ]; then
    JSON_CONTENT=$(cat "$JSON_FILE")
    echo "JSON file content:"
    JSON_ARRAY=($(echo "$JSON_CONTENT" | jq -r '.[].item'))
    echo $JSON_ARRAY
else
    echo "JSON file not found: $JSON_FILE"
    exit 1
fi

# Parse JSON array


# Loop through the array and execute transfer.sh with each item
# for ITEM in "${JSON_ARRAY[@]}"; do
#     echo "Executing transfer.sh with item: $ITEM"
#     bash transfer.sh "$ITEM"
# done

# Print message before transferring
echo "Transferring..."

# Use rsync to transfer the source path to the destination path
#rsync -avz -e "ssh" --include="*/" --include="*.*" --exclude="*" "$SOURCE_PATH" "$DESTINATION_USER@$DESTINATION_IP:$DESTINATION_PATH"

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Transfer successful"
else
    echo "Transfer failed"
fi
