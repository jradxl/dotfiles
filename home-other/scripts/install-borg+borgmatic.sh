#!/bin/bash

### BORG and BORGMATIC ###
#Intentionally, Borg is installed as root user using pipx install --gloabl. 
#Therefore must be run as root for the venvs to work.

### WARNING WARNING the PYPI package is BORGBACKUP and NOT "BORG"

# If installed from packages are too old, and not using v2.
echo "Uninstalling borgbackup and borgmatic Ubuntu packages if present as too old."
sudo apt-get -y purge borgbackup borgbackup borgmatic  2>/dev/null >/dev/null

if [[ ! $(command -v pipx) ]]; then
	echo "Pipx needs to be installed first. Run install_pipx.sh"
	exit 1
fi

echo "Uninstalling from this user account if present"
pipx uninstall borgbackup 2>/dev/null >/dev/null
pipx uninstall borgmatic 2>/dev/null >/dev/null

if [[ $(sudo ls /root/.local/bin/borg 2>/dev/null) ]]; then
	echo "Borgbackup: Old root installation detected. Removing..."
    sudo pipx uninstall --global borgbackup
    sudo pipx --global  uninstall borgbackup
	sudo pipx uninstall borgbackup
fi

if [[ $(sudo ls /root/.local/bin/borgmatic 2>/dev/null) ]]; then
	echo "Borgmatic: Old root installation detected. Removing..."
    sudo pipx uninstall --global borgmatic
    sudo pipx --global uninstall borgmatic
    sudo pipx uninstall borgmatic
fi

if [[ $(sudo ls /usr/local/bin/borg 2>/dev/null) ]]; then
	echo "Borgbackup: Global install is already present."
else
	echo "Borgbackup: Installing globally."
	##NOTE position of --global. Was/Is a Pipx bug.

    sudo apt-get -y install \
    python3 \
    python3-dev \
    python3-pip \
    python3-virtualenv \
    python3-venv \
    libssl-dev \
    openssl \
    libacl1-dev \
    libacl1 \
    liblz4-dev \
    liblz4-1 \
    libzstd-dev \
    libxxhash-dev \
    build-essential

    #NO attempts to remove flatpak sudo apt-get install libfuse-dev fuse pkg-config 
    sudo apt-get install libfuse3-dev fuse3 pkg-config -y
	#sudo pipx install --global borgbackup
	sudo pipx install --preinstall pyfuse3 --global borgbackup
fi

if [[ $(sudo ls /usr/local/bin/borgmatic 2>/dev/null) ]]; then
	echo "Borgmatic: Global install is already present."
else
	echo "Borgmatic: Installing globally."
	##NOTE position of --global. Was/Is a Pipx bug.
	sudo pipx install --global borgmatic
fi
if [[ $(command -v borg) ]]; then
echo "borgmatic: $(borg --version)"
else
    echo "No BORG. Script error!"
fi

if [[ $(command -v borgmatic) ]]; then
    echo "borgmatic: $(borgmatic --version)"
else
    echo "No BORGMATIC Script error!"
fi

exit 0

#### End Borg and Borgmatic

