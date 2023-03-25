#!/bin/bash

# Parse command line arguments
DOMAIN="$1"
PASSWORD="$2"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: add-phpmyadmin.sh example.com password"
    exit 1
fi

# Check if the MySQL root password is provided
if [ -z "$PASSWORD" ]
then
    echo "MySQL root password is required"
    echo "Usage: add-phpmyadmin.sh example.com password"
    exit 1
fi

# Check if the domain directory exists
if [ ! -d "/var/www/$DOMAIN" ]
then
    echo "Domain directory not found"
    exit 1
fi

# Install phpMyAdmin
sudo apt update
sudo apt install phpmyadmin -y

# Create a symbolic link for phpMyAdmin in the domain directory
sudo ln -s /usr/share/phpmyadmin /var/www/$DOMAIN/phpmyadmin

# Modify the Nginx configuration to enable PHP and add a location block for phpMyAdmin
sudo sed -i "s/# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000/pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000\n\tlocation \/phpmyadmin {\n\t\talias \/var\/www\/$DOMAIN\/phpmyadmin;\n\t\tindex index.php;\n\t}\n/g" /etc/nginx/sites-available/$DOMAIN
sudo systemctl restart nginx

# Create an .htpasswd file to protect the phpMyAdmin directory with a password
sudo apt install apache2-utils -y
sudo htpasswd -cb /var/www/$DOMAIN/phpmyadmin/.htpasswd phpmyadmin $PASSWORD

# Modify the Nginx configuration to require authentication for the phpMyAdmin directory
sudo sed -i "s/# location \/ {/auth_basic \"Restricted Access\";\n\tauth_basic_user_file \/var\/www\/$DOMAIN\/phpmyadmin\/.htpasswd;\n\n\tlocation \/ {\n/g" /etc/nginx/sites-available/$DOMAIN
sudo systemctl restart nginx

# Print confirmation message
echo "phpMyAdmin installed successfully for $DOMAIN"
echo "phpMyAdmin is accessible at http://$DOMAIN/phpmyadmin"
