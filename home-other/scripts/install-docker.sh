#!/bin/bash

#https://docs.docker.com/engine/security/rootless/
#INFO sudo machinectl shell $USER@ or use ssh

# Remove Older packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg uidmap dbus-user-session systemd-container
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -y update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

#Rootful test
sudo docker run hello-world

echo "NOTE: Do you want to test Docker as a Non-Root user. This account?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
			echo "Continuing..."
			break
			;;
        No )
			echo "Exiting..."
			exit 0
			;;
    esac
done

sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

#Rootful as Non-Root User
sudo groupadd docker
#sudo adduser $USER
#sudo adduser $USER sudo
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world

echo "NOTE: Do you want to continue install as Rootless?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
			echo "Continuing..."
			break
			;;
        No )
			echo "Exiting..."
			exit 0
			;;
    esac
done

sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock

/usr/bin/##dockerd-rootless-setuptool.sh install

exit 0

