#!/bin/bash

# Install Varnish
sudo apt update
sudo apt install varnish -y

# Backup the default Varnish configuration
sudo cp /etc/varnish/default.vcl /etc/varnish/default.vcl.bak

# Create a new Varnish configuration
sudo touch /etc/varnish/default.vcl
sudo cat << EOF > /etc/varnish/default.vcl
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
EOF

# Modify the Nginx configuration to listen on port 8080
sudo sed -i "s/listen 80;/listen 127.0.0.1:8080;/g" /etc/nginx/sites-available/*
sudo systemctl restart nginx

# Modify the Varnish systemd service file to listen on port 80
sudo sed -i "s/:6081/:80/g" /lib/systemd/system/varnish.service

# Reload systemd
sudo systemctl daemon-reload

# Restart Varnish
sudo systemctl restart varnish

# Enable Varnish to start on boot
sudo systemctl enable varnish

# Print installation confirmation message
echo "Varnish installed successfully"
echo "Nginx is now listening on port 8080"
echo "Varnish is now listening on port 80 and caching requests to Nginx" 
