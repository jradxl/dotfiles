#!/bin/bash

### BORG and BORGMATIC ###
#Intentionally, Borg is installed as root user using pipx install --gloabl. 
#Therefore must be run as root for the venvs to work.

### WARNING WARNING the PYPI package is BORGBACKUP and NOT "BORG"

CONFIG_FILE=config.yaml
CONFIG_DIR=/etc/borgmatic

# If installed from packages they are too old    
echo "Uninstalling borgbackup and borgmatic Ubuntu packages if present as too old."
sudo apt-get -y purge borgbackup borgmatic  2>/dev/null >/dev/null

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

#NO, not this. Attempts to remove flatpak sudo apt-get install libfuse-dev fuse pkg-config 
sudo apt-get install libfuse3-dev fuse3 pkg-config -y
    
if [[ $(sudo ls /usr/local/bin/borg 2>/dev/null) ]]; then
	echo "Borgbackup: Global install is already present."
else
	echo "Borgbackup: Installing globally."
	##NOTE position of --global. Was/Is a Pipx bug.
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
    echo "No BORG: Script error!"
fi

if [[ $(command -v borgmatic) ]]; then
    echo "borgmatic: $(borgmatic --version)"
else
    echo "No BORGMATIC: Script error!"
fi

mkdir -p /etc/borgmatic/
if [[ ! -f /etc/borgmatic/config.yaml ]]; then

##Two stage HereDoc needed due to SUDO
cat << EOF > /tmp/$CONFIG_FILE

source_directories:
    - /home
    - /etc
    - /root
    - /var/www

repositories:
    - path: ssh://XXXXXX@XXXXXX.repo.borgbase.com/./repo
      label: XXXXX

one_file_system: true

exclude_patterns:
    - '*.pyc'
    - /home/*/.cache
    - '*/.vim*.tmp'
    - /etc/ssl
    - /home/*/Downloads
    - '*.iso'
    - /home/jradley-other

exclude_caches: true
exclude_if_present:
    - .nobackup
ssh_command: ssh -i /root/.ssh/my-keys/XXXXX.key
compression: auto,zstd
encryption_passphrase: XXXXXXX
archive_name_format: '{hostname}-{now:%Y-%m-%d-%H%M%S}'
retries: 5
retry_wait: 5
keep_daily: 3
keep_weekly: 4
keep_monthly: 12
keep_yearly: 2

checks:
    - name: repository
    - name: archives
    - name: data

check_last: 3

before_backup:
    - echo "$(date) - Starting backup"
after_backup:
    - echo "$(date)  - Finished backup"

EOF
    sudo mv /tmp/"$CONFIG_FILE" "$CONFIG_DIR"
else
    echo "Not overwriting the config file."
fi

echo "Borg and Borgmatic install finished."
echo "Update the config file with correct values."
exit 0

#### End Borg and Borgmatic

