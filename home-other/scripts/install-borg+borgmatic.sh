#!/bin/bash

### BORG and BORGMATIC ###
#Intentionally, Borg is installed as root user using pipx install --gloabl. 
#Therefore must be run as root for the venvs to work.

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
	sudo pipx uninstall borgbackup
fi

if [[ $(sudo sudo ls /root/.local/bin/borgmatic 2>/dev/null) ]]; then
	echo "Borgmatic: Old root installation detected. Removing..."
	sudo pipx uninstall borgmatic
fi

if [[ $(sudo ls /usr/local/bin/borg 2>/dev/null) ]]; then
	echo "Borgbackup: Global install is already present."
else
	echo "Borgbackup: Installing globally."
	##NOTE position of --global. Was/Is a Pipx bug.
	sudo pipx install --global borgbackup
fi

if [[ $(sudo ls /usr/local/bin/borgmatic 2>/dev/null) ]]; then
	echo "Borgmatic: Global install is already present."
else
	echo "Borgmatic: Installing globally."
	##NOTE position of --global. Was/Is a Pipx bug.
	sudo pipx install --global borgmatic
fi

borg --version
echo "borgmatic $(borgmatic --version)"

exit 0

#### End Borg and Borgmatic

