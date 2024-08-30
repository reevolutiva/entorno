echo "uso: ./demyx-transfer.sh WORDPRESS_SITE  MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH DEMYX"

# Use command line arguments instead of prompts
WORDPRESS_SITE=$1
MYSQL_USER=$2
MYSQL_PASSWORD=$3
MYSQL_DATABASE=$4
REMOTE_USER=$5
REMOTE_HOST=$6
REMOTE_PATH=$7
DEMYX=$8

WORDPRESS_SITE_PATH="/var/lib/docker/volumes"




# Extract the WordPress site from the server origin
#cd $WORDPRESS_SITE_PATH

# Check if DEMYX is not false and search for the specified folders
if [[ "$DEMYX" != "false" ]]; then
    DEMYX_WP_FOLDER="$WORDPRESS_SITE_PATH/wp_$DEMYX/"
    DEMYX_DB_FOLDER="$WORDPRESS_SITE_PATH/wp_${DEMYX}_db/"

    echo $DEMYX
    echo $DEMYX_DB_FOLDER

    echo $DEMYX_WP_FOLDER

    if [ -d "$DEMYX_WP_FOLDER" ]; then
        cd $DEMYX_WP_FOLDER
        zip -r ./$WORDPRESS_SITE.zip ./_data/
    else
        echo "$DEMYX_WP_FOLDER folder not found."
    fi

    if [ -d "$DEMYX_DB_FOLDER" ]; then
        cd $DEMYX_DB_FOLDER
        # Extract the BDD from the WordPress site
        demyx exec $WORDPRESS_SITE -d mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $DEMYX_DB_FOLDER$WORDPRESS_SITE.sql
    else
        echo "$DEMYX_DB_FOLDER folder not found."
    fi

    #rsync -a -e ssh $DEMYX_WP_FOLDER/$WORDPRESS_SITE.zip $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
    #rsync -a -e ssh $DEMYX_DB_FOLDER/$WORDPRESS_SITE.sql $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/
fi

