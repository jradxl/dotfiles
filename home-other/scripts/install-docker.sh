#!/bin/bash

#https://docs.docker.com/engine/security/rootless/
#INFO sudo machinectl shell $USER@ or use ssh

echo "Docker ROOTFUL and optional ROOTLESS install"

echo "Test Current Running method: $(docker info 2>/dev/null  | grep "Docker Root Dir" )"

# Remove Older packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg uidmap dbus-user-session systemd-container
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -y update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras slirp4netns

sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

if [ $(getent group docker) ]; then
  echo "Docker group already exists."
else
  echo "Adding Docker group."
  sudo groupadd docker
fi

unset DOCKER_HOST
sudo docker context use default

#Rootful test
sudo docker run hello-world

echo "NOTE: Do you want to test ROOTFUL Docker as a Non-Root user. This account?"
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

if [[ $(getent group docker | grep -w $USER) ]]; then
    echo "$USER is already a member of the Docker group."
else
  sudo usermod -aG docker $USER
  echo "$USER added to Docker group. This script will now exit so you can open a new terminal."
  exit 0
fi

unset DOCKER_HOST

#Rootful test as non-root user
docker run hello-world

echo ""
echo "Docker ROOTFUL is complete. See both 'docker run hello-world' above."
echo "Do you want to continue to enable ROOTLESS docker:"
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
sudo rm -f /var/run/docker.sock
#sudo systemctl stop docker.service
#sudo systemctl stop containerd.service
#sudo systemctl disable docker.service
#sudo systemctl disable containerd.service

#Just in case...
if [[ -d /home/"$USER"/.docker ]]; then
    sudo chown -R "$USER":"$USER" /home/"$USER"/.docker
    sudo chmod -R g+rwx "$HOME/.docker"
fi

if [[ -f /usr/bin/dockerd-rootless-setuptool.sh ]]; then
    echo "Checking Docker Rootless conditions are met."
    /usr/bin/dockerd-rootless-setuptool.sh check
    if [[ "$?" == 0 ]]; then
        echo "Success: Now starting ROOTLESS setup..."
         /usr/bin/dockerd-rootless-setuptool.sh install
    else
        echo "Error: Conditions unmet."
        exit 1
    fi
else
    echo "The dockerd-rootless-setuptool.sh does not appear to be available."
    exit 1
fi

sudo loginctl enable-linger "$USER"

docker run hello-world

echo "ROOTLESS setup completed"

