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

# Add your code here to deactivate the container using the provided src path
echo "Deactivating container for path: $src"
