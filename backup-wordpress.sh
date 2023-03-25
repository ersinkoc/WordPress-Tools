#!/bin/bash

# Parse command line arguments
DOMAIN="$1"
BACKUP_DIR="/var/backups/$DOMAIN"
DATE="$(date +%Y-%m-%d-%H-%M-%S)"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: backup-wordpress.sh example.com"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]
then
    sudo mkdir -p "$BACKUP_DIR"
fi

# Backup the WordPress database
MYSQL_COMMAND="mysqldump -uroot -pPASSWORD wpdb_$DOMAIN"
sudo $MYSQL_COMMAND > "$BACKUP_DIR/$DOMAIN-$DATE.sql"

# Backup the WordPress files
sudo tar -czf "$BACKUP_DIR/$DOMAIN-$DATE.tar.gz" -C /var/www/$DOMAIN/html .

# Print backup confirmation message
echo "WordPress backup created at $BACKUP_DIR/$DOMAIN-$DATE.sql and $BACKUP_DIR/$DOMAIN-$DATE.tar.gz"
