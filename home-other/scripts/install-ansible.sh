#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Returns 0 if not installed
apt-cache policy ansible | grep none &>/dev/null
RET=$?
if [[ $RET == 0 ]]; then
    echo "Good! Ubuntu Ansible package is NOT installed"
    echo ""
fi

if [[ $RET == 1 ]]; then
    echo "Ubuntu Ansible package installed. Purging..."
    apt-get purge ansible -y
    apt-get autoremove -y
    echo ""
fi

if [[ $(command -v  pipx) ]]; then
    echo "Found Pipx."
    
    pipx list --global | grep -q ansible &>/dev/null
    RET=$?

    if [[  $RET == 1 ]]; then
        echo "Ansible Not Found. Installing..."
        pipx install --include-deps ansible --global
    else
        echo "Ansible Found. Upgrading..."
        pipx upgrade --include-injected ansible --global
    fi
else
    echo "PIPX is not installed..."
    exit 1
fi


exit 0

##
## This method os deprecated
##
UBUNTU_CODENAME=noble
FILENAME="ansible-ubuntu-ansible-$UBUNTU_CODENAME.sources"

cat << EOF > "/etc/apt/sources.list.d/$FILENAME"
Types: deb
URIs: https://ppa.launchpadcontent.net/ansible/ansible/ubuntu/
Suites: $UBUNTU_CODENAME
Components: main
Signed-By: /usr/share/keyrings/ansible-archive-keyring.gpg
EOF


#Allow overwriting
rm -f /usr/share/keyrings/ansible-archive-keyring.gpg

wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --dearmor -o /usr/share/keyrings/ansible-archive-keyring.gpg

#wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" >  /usr/share/keyrings/ansible-archive-keyring.gpg

#echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/$FILENAME
apt update && apt install ansible

exit 0

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

ansible --version

exit 0
