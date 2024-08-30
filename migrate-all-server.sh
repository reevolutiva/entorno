#!/bin/bash

while getopts ":l:u:h:p:" opt; do
    case $opt in
        l) LOCAL_ROUTE=$OPTARG ;;
        u) REMOTE_USER=$OPTARG ;;
        h) REMOTE_HOST=$OPTARG ;;
        p) REMOTE_PATH=$OPTARG ;;
        \?) echo "Invalid option -$OPTARG" >&2 ;;
    esac
done

#rsync -a -e ssh $LOCAL_ROUTE $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
