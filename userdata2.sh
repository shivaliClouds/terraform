#!/bin/bash
apt update && apt upgrade -y
apt install apache2 -y
systemctl enable apache2 #to enable apache to start on boot
systemctl start apache2 #to start apache service
echo "<h1>Hey, welcome to the site !</h1>" > /var/www/html/index.html #add data to the index file
