#!/bin/bash

# Parse command line arguments
DOMAIN="$1"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: remove-varnish-cache.sh example.com"
    exit 1
fi

# Check if the domain exists in Nginx
if [ ! -f "/etc/nginx/sites-available/$DOMAIN" ]
then
    echo "Site not found in Nginx"
    exit 1
fi

# Check if Varnish is already disabled for the domain
if ! grep -q "# Varnish Cache" "/etc/nginx/sites-available/$DOMAIN"
then
    echo "Varnish is already disabled for $DOMAIN"
    exit 1
fi

# Modify the Nginx configuration to remove Varnish cache
sudo sed -i "/# Varnish Cache/,/}/ d" "/etc/nginx/sites-available/$DOMAIN"
sudo systemctl restart nginx

# Print confirmation message
echo "Varnish cache disabled successfully for $DOMAIN"
