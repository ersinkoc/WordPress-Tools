#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install MySQL
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql_secure_installation

# Install PHP and extensions
sudo apt install php8.0-fpm php8.0-mysql php8.0-curl php8.0-gd php8.0-mbstring php8.0-xml php8.0-zip -y

# Configure Nginx to use PHP-FPM
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
sudo touch /etc/nginx/sites-available/default
sudo cat << EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name _;

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

# Restart Nginx
sudo systemctl restart nginx

# Create a PHP test file
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Change ownership of the web directory to the web server user
sudo chown -R www-data:www-data /var/www/html
