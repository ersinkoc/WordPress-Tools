#!/bin/bash

# Parse command line arguments
DOMAIN="$1"
FTP_USER="$2"
FTP_PASS="$3"

# Check if the domain name is provided
if [ -z "$DOMAIN" ]
then
    echo "Domain name is required"
    echo "Usage: ftp-user.sh example.com user pass"
    exit 1
fi

# Check if the FTP user is provided
if [ -z "$FTP_USER" ]
then
    echo "FTP user is required"
    echo "Usage: ftp-user.sh example.com user pass"
    exit 1
fi

# Check if the FTP password is provided
if [ -z "$FTP_PASS" ]
then
    echo "FTP password is required"
    echo "Usage: ftp-user.sh example.com user pass"
    exit 1
fi

# Check if the domain directory exists
if [ ! -d "/var/www/$DOMAIN" ]
then
    echo "Domain directory not found"
    exit 1
fi

# Check if vsftpd is already installed
if ! command -v vsftpd &> /dev/null
then
    # Install vsftpd FTP server
    sudo apt update
    sudo apt install vsftpd -y

    # Backup the vsftpd configuration file
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

    # Modify the vsftpd configuration file to allow local users to access FTP
    sudo sed -i "s/#write_enable=YES/write_enable=YES/g" /etc/vsftpd.conf
    sudo sed -i "s/#local_umask=022/local_umask=022/g" /etc/vsftpd.conf
    sudo sed -i "s/#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd.conf
    sudo sed -i "s/#allow_writeable_chroot=YES/allow_writeable_chroot=YES/g" /etc/vsftpd.conf

    # Restart the vsftpd service
    sudo systemctl restart vsftpd
fi

# Add a new FTP user for the domain
sudo useradd -m -d /var/www/$DOMAIN -s /usr/sbin/nologin $FTP_USER
echo "$FTP_USER:$FTP_PASS" | sudo chpasswd

# Add the FTP user to the www-data group to enable write access to the domain directory
sudo usermod -a -G www-data $FTP_USER

# Modify the ownership and permissions of the domain directory
sudo chown -R www-data:www-data /var/www/$DOMAIN
sudo chmod -R g+w /var/www/$DOMAIN

# Print confirmation message
echo "FTP user $FTP_USER added successfully for $DOMAIN"
echo "FTP server is now running on port 21"
