#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --domain)
            DOMAIN="$2"
            shift
            shift
            ;;
        --ssl)
            SSL="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required (--domain)"
    exit 1
fi

# Create web directory
sudo mkdir -p /var/www/$DOMAIN/html

# Create a PHP test file
sudo echo "<?php phpinfo(); ?>" > /var/www/$DOMAIN/html/info.php

# Change ownership of the web directory to the web server user
sudo chown -R www-data:www-data /var/www/$DOMAIN/html

# Create Nginx server block
sudo touch /etc/nginx/sites-available/$DOMAIN
sudo cat << EOF > /etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    listen [::]:80;
    root /var/www/$DOMAIN/html;
    index index.php index.html index.htm;
    server_name $DOMAIN www.$DOMAIN;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.0-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the site by creating a symlink
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx

# Enable SSL if requested
if [ "$SSL" == "true" ]
then
    # Install Certbot
    sudo add-apt-repository ppa:certbot/certbot -y
    sudo apt update
    sudo apt install certbot python3-certbot-nginx -y

    # Obtain and install SSL certificate
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN
fi

# Print instructions for accessing the site
echo "Website created at /var/www/$DOMAIN/html"
if [ "$SSL" == "true" ]
then
    echo "Website URL: https://$DOMAIN"
else
    echo "Website URL: http://$DOMAIN"
fi
