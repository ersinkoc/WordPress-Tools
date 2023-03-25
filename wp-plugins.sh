#!/bin/bash

# Parse command line arguments
DOMAIN="$1"
PLUGINS="$2"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: wp-plugins.sh example.com all|plugin1 plugin2 ..."
    exit 1
fi

# Check if the plugins are provided
if [ -z "$PLUGINS" ]
then
    echo "Plugins are required"
    echo "Usage: wp-plugins.sh example.com all|plugin1 plugin2 ..."
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

# Plugin list
PLUGINS_LIST=("jetpack" "akismet" "contact-form-7" "wp-super-cache")

# Install all popular plugins
if [ "$PLUGINS" == "all" ]
then
    PLUGINS_TO_INSTALL=${PLUGINS_LIST[@]}
else
    # Filter plugins to install
    PLUGINS_TO_INSTALL=()
    for PLUGIN in $PLUGINS
    do
        if [[ " ${PLUGINS_LIST[@]} " =~ " ${PLUGIN} " ]]
        then
            PLUGINS_TO_INSTALL+=($PLUGIN)
        fi
    done
fi

# Install selected plugins
if [ ${#PLUGINS_TO_INSTALL[@]} -eq 0 ]
then
    echo "No plugins to install"
else
    for PLUGIN in ${PLUGINS_TO_INSTALL[@]}
    do
        echo "Installing plugin: $PLUGIN"
        sudo wp plugin install $PLUGIN --activate --allow-root
    done
fi

# Print installation confirmation message
echo "WordPress plugins installed successfully for $DOMAIN"
