#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y curl ca-certificates
sudo apt-get purge -y postgresql-common
sudo apt-get autoremove -y
sudo apt install -y postgresql-common
sudo apt purge -y postgresql-client-14 postgresql-client-16 postgresql-client-common

#DO NOT INSTALL VERSION 18
#sudo apt install -y postgresql-common
#sudo install -d /usr/share/postgresql-common/pgdg
#sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

sudo apt update -y
sudo apt install -y postgresql
echo "Postgresql version 16 is installed..."
/usr/lib/postgresql/16/bin/postgres --version
echo "USE: systemctl status postgresql@16-main"
echo "The default port for version 16 is 5433"

#
# Setup the pgAdmin repository
#
sudo apt-get update -y && sudo apt-get upgrade -y

sudo rm -f /usr/share/keyrings/packages-pgadmin-org.gpg

# Install the public key for the repository (if not done previously):
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | \
    sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

# Create the repository configuration file:
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

#
# Install pgAdmin
#
sudo apt update -y

# Install for both desktop and web modes:
#sudo apt install -y pgadmin4

# Install for desktop mode only:
sudo apt install -y pgadmin4-desktop

# Install for web mode only: 
## sudo apt install pgadmin4-web 

# Configure the webserver, if you installed pgadmin4-web:
## sudo /usr/pgadmin4/bin/setup-web.sh

exit 0

