#!/bin/bash -x

# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
# Log everything
#
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/cloud-config-detail.log 2>&1

wget https://gist.githubusercontent.com/jdmedeiros/1add075e054c911776d26e97a84dfdec/raw/62c0ccd0e8d76e0dc9d1b15fe369d101dd7bc12f/logger.sh
source ./logger.sh

SCRIPTENTRY
DEBUG "Script starting."
sudo sh -c 'echo root:Passw0rd | chpasswd'
sudo apt-get update && sudo apt-get -y upgradecloud-config.sh
INFO "System updated and upgraded."

sudo apt-get -y install apache2
INFO "Software packages installed."
sudo a2enmod ssl
sudo a2ensite default-ssl.conf
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/001-default.conf
sudo sed -i -e 's/:80/:8080/g' /etc/apache2/sites-available/001-default.conf
sudo sed -i -e 's/:443/:8443/g' /etc/apache2/sites-available/default-ssl.conf
sudo chown -R www-data:www-data /var/www/*
sudo sed -i -e 's/Listen 80/Listen 80\nListen 8080/g' /etc/apache2/ports.conf
sudo sed -i -e 's/Listen 443/Listen 443\nListen 8443/g' /etc/apache2/ports.conf
sudo mkdir "/var/www/htmls"
sudo sed -i -e 's/html/htmls/g' /etc/apache2/sites-available/default-ssl.conf
sudo touch /var/www/htmls/index.html
sudo systemctl restart apache2
INFO "Web sited created. Joomla on port 80 and Moodle on port 8080."
DEBUG "Script reached the end."
SCRIPTEXIT

rm logger.sh
