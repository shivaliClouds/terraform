#!/bin/bash
apt update && apt upgrade -y
apt install apache2 -y
systemctl enable apache2 #to enable apache to start on boot
systemctl start apache2 #to start apache service
echo "<h1> welcome again but it's a different server !</h1>" > /var/www/html/index.html #add data to the index file
