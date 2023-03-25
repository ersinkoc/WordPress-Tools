#!/bin/bash

# Parse command line arguments
DOMAIN="$1"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: wordpress-install.sh example.com"
    exit 1
fi

# Check if the domain exists in Nginx
if [ ! -f "/etc/nginx/sites-available/$DOMAIN" ]
then
    echo "Site not found in Nginx"
    exit 1
fi

# Generate a random prefix for the database tables
PREFIX="$(openssl rand -hex 3)_"

# Generate a random password for the admin user
PASSWORD="$(openssl rand -base64 12)"

# Ask for MySQL root password
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD

# Create MySQL database and user
MYSQL_COMMAND="mysql -uroot -p$MYSQL_ROOT_PASSWORD"
DATABASE_NAME="wpdb_$DOMAIN"
DATABASE_USER="wpuser_$DOMAIN"
DATABASE_PASSWORD="$(openssl rand -base64 12)"
$MYSQL_COMMAND -e "CREATE DATABASE $DATABASE_NAME;"
$MYSQL_COMMAND -e "CREATE USER '$DATABASE_USER'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD';"
$MYSQL_COMMAND -e "GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DATABASE_USER'@'localhost';"
$MYSQL_COMMAND -e "FLUSH PRIVILEGES;"

# Download and extract WordPress
sudo curl -O https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz

# Copy WordPress files to the web directory
sudo rsync -av wordpress/* /var/www/$DOMAIN/html

# Copy the sample configuration file and create a new one
sudo cp /var/www/$DOMAIN/html/wp-config-sample.php /var/www/$DOMAIN/html/wp-config.php

# Set database credentials in the WordPress configuration file
sudo sed -i "s/database_name_here/$DATABASE_NAME/g" /var/www/$DOMAIN/html/wp-config.php
sudo sed -i "s/username_here/$DATABASE_USER/g" /var/www/$DOMAIN/html/wp-config.php
sudo sed -i "s/password_here/$DATABASE_PASSWORD/g" /var/www/$DOMAIN/html/wp-config.php
sudo sed -i "s/wp_/$PREFIX/g" /var/www/$DOMAIN/html/wp-config.php

# Set the WordPress salts
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/$DOMAIN/html/wp-config.php

# Set the default WordPress theme and plugins to download
sudo sed -i "s/'wp-content\/themes\/'/'wp-content\/themes\/twentytwentytwo\/'/g" /var/www/$DOMAIN/html/wp-admin/includes/upgrade.php
sudo sed -i "s/'wp-content\/plugins\/'/'wp-content\/plugins\/akismet\/','wp-content\/plugins\/hello.php',/g" /var/www/$DOMAIN/html/wp-admin/includes/upgrade.php

# Set the file permissions
sudo chown -R www-data:www-data /var/www/$DOMAIN/html
sudo find /var/www/$DOMAIN/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/$DOMAIN/html/ -type f -exec chmod 644 {} \;

# Clean up
sudo rm -rf latest.tar.gz wordpress

# Print the admin user password
echo "WordPress installed successfully"
echo "Admin password: $PASSWORD"
echo "Website URL: https://$DOMAIN"
