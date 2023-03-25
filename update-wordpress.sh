#!/bin/bash

# Parse command line arguments
DOMAIN="$1"
TYPE="$2"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: update-wordpress.sh example.com all/themes/plugins/wordpress"
    exit 1
fi

# Check if the update type is provided
if [ -z "$TYPE" ]
then
    echo "Update type is required"
    echo "Usage: update-wordpress.sh example.com all/themes/plugins/wordpress"
    exit 1
fi

# Check if the domain exists in Nginx
if [ ! -f "/etc/nginx/sites-available/$DOMAIN" ]
then
    echo "Site not found in Nginx"
    exit 1
fi

# Change directory to the WordPress installation
cd /var/www/$DOMAIN/html

# Update WordPress core files
if [ "$TYPE" == "all" ] || [ "$TYPE" == "wordpress" ]
then
    sudo wp core update --allow-root
fi

# Update plugins
if [ "$TYPE" == "all" ] || [ "$TYPE" == "plugins" ]
then
    sudo wp plugin update --all --allow-root
fi

# Update themes
if [ "$TYPE" == "all" ] || [ "$TYPE" == "themes" ]
then
    sudo wp theme update --all --allow-root
fi

# Print update confirmation message
echo "WordPress, $TYPE updated successfully for $DOMAIN"
