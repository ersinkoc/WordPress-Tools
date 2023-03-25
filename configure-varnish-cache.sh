#!/bin/bash

# Parse command line arguments
DOMAIN="$1"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: configure-varnish-cache.sh example.com"
    exit 1
fi

# Check if the domain exists in Nginx
if [ ! -f "/etc/nginx/sites-available/$DOMAIN" ]
then
    echo "Site not found in Nginx"
    exit 1
fi

# Check if Varnish is already enabled for the domain
if ! grep -q "# Varnish Cache" "/etc/nginx/sites-available/$DOMAIN"
then
    echo "Varnish cache is not enabled for $DOMAIN"
    echo "Use add-varnish-cache.sh script to enable Varnish cache for the domain"
    exit 1
fi

# Change directory to the WordPress installation
cd /var/www/$DOMAIN/html

# Install the Varnish HTTP Purge plugin for WordPress
sudo wp plugin install varnish-http-purge --activate --allow-root

# Modify the wp-config.php file to configure the Varnish cache
sudo sed -i "/^\$table_prefix/a define('VHP_VARNISH_IP', '127.0.0.1');\ndefine('VHP_VARNISH_PORT', '80');\ndefine('VHP_ENABLED', true);" wp-config.php

# Print confirmation message
echo "WordPress site configured to use Varnish cache for $DOMAIN"
