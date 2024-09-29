#!/bin/bash

##Check and upgrade Nebula VPN as root

##Dependancies: PIPX and LASTVERSION
## apt install pipx
## pipx install lastversion
## then add PATH

latest_nebula=$(lastversion https://github.com/slackhq/nebula)
echo "Latest Nebula is: ${latest_nebula}"
if command -v nebula > /dev/null 2>&1 ; then
    current_nebula=$(nebula -version )
    current_nebula=${current_nebula: 9}
    echo "Current Nebula is: ${current_nebula}"
else
    echo "Nebula not installed"
    current_nebula=""
fi

if [[ ${current_nebula} == "${latest_nebula}" ]]; then
	echo "Nebula is the latest version"
else
	echo "Installing/Upgrading Nebula..."
	rm -rf ./nebula-linux-amd64.tar.gz ./nebula ./nebula-cert
	## https://github.com/slackhq/nebula/releases/download/v1.8.1/nebula-linux-amd64.tar.gz
	wget https://github.com/slackhq/nebula/releases/download/v"${latest_nebula}"/nebula-linux-amd64.tar.gz
	tar xf nebula-linux-amd64.tar.gz
	sudo chown root:root ./nebula ./nebula-cert
	sudo systemctl stop nebula
	sudo mv nebula /usr/local/bin
	sudo mv nebula-cert /usr/local/bin
	rm -rf ./nebula-linux-amd64.tar.gz
        sudo systemctl start nebula
fi
