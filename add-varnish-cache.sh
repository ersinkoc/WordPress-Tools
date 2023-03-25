#!/bin/bash

# Parse command line arguments
DOMAIN="$1"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: add-varnish-cache.sh example.com"
    exit 1
fi

# Check if the domain exists in Nginx
if [ ! -f "/etc/nginx/sites-available/$DOMAIN" ]
then
    echo "Site not found in Nginx"
    exit 1
fi

# Check if Varnish is already enabled for the domain
if grep -q "# Varnish Cache" "/etc/nginx/sites-available/$DOMAIN"
then
    echo "Varnish is already enabled for $DOMAIN"
    exit 1
fi

# Modify the Nginx configuration to use Varnish cache
sudo sed -i "/listen 80;/ a \ \n\t# Varnish Cache\n\tlisten 127.0.0.1:80;\n\tlocation / {\n\t\tproxy_pass http://127.0.0.1:6081;\n\t\tproxy_set_header Host \$host;\n\t\tproxy_set_header X-Real-IP \$remote_addr;\n\t\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\t\tproxy_set_header X-Forwarded-Proto \$scheme;\n\t}" "/etc/nginx/sites-available/$DOMAIN"
sudo systemctl restart nginx

# Print confirmation message
echo "Varnish cache enabled successfully for $DOMAIN"
