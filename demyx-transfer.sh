echo "uso: ./demyx-transfer.sh WORDPRESS_SITE WORDPRESS_SITE_PATH MYSQL_HOST MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH"

# Use command line arguments instead of prompts
WORDPRESS_SITE=$1
WORDPRESS_SITE_PATH=$2
MYSQL_HOST=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$5
MYSQL_DATABASE=$6
REMOTE_USER=$7
REMOTE_HOST=$8
REMOTE_PATH=$9

DEMYX="3cj9i" 



# Extract the WordPress site from the server origin
#cd $WORDPRESS_SITE_PATH

# Check if DEMYX is not false and search for the specified folders
if [[ "$DEMYX" != "false" ]]; then
    DEMYX_WP_FOLDER="$WORDPRESS_SITE_PATH/wp_$DEMYX/"
    DEMYX_DB_FOLDER="$WORDPRESS_SITE_PATH/wp_${DEMYX}_db/"

    echo $DEMYX_WP_FOLDER

    if [ -d "$DEMYX_WP_FOLDER" ]; then
        cd $DEMYX_WP_FOLDER
        ls -la
        #zip -r ./$WORDPRESS_SITE.zip ./_data/
    else
        echo "$DEMYX_WP_FOLDER folder not found."
    fi

    if [ -d "$DEMYX_DB_FOLDER" ]; then
        cd $DEMYX_DB_FOLDER
        ls -la
        # Extract the BDD from the WordPress site
        #mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > $DEMYX_DB_FOLDER$WORDPRESS_SITE.sql
    else
        echo "$DEMYX_DB_FOLDER folder not found."
    fi
fi