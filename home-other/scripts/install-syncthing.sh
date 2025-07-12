#!/bin/bash

echo "Installing Syncthing and MMV. Will ask for SUDO password."
if [[ ! $(command -v mmv) ]]; then
    sudo apt-get install -y mmv
else
    echo "Good! MMV already installed"
fi

#RET=$(dpkg -l apt-transport-https | grep "un")
#echo "RET: $RET"

if [[ ! $(dpkg -s apt-transport-https 2>/dev/null) ]]; then
    sudo apt-get install -y apt-transport-https
fi

sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt-get update
sudo apt-get -y install syncthing

echo ""
echo "Assuming installing for youself, $USER"
sudo systemctl status syncthing@$USER
    
if [[ ! -f /etc/systemd/system/syncthing@.service ]]; then
    sudo mcp "/lib/systemd/system/syncthing*" /etc/systemd/system
    sudo systemctl daemon-reload
else
    echo ""
    echo "/etc/systemd/system/syncthing@.service already present, not overwrting"
fi

exit 0

