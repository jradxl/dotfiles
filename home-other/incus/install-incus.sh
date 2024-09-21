#!/bin/bash

wget -q -O - https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint
sudo mkdir -p /etc/apt/keyrings/
sudo wget -O /etc/apt/keyrings/zabbly.asc https://pkgs.zabbly.com/key.asc
sudo sh -c "cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc
EOF"

sudo apt-get -y update
sudo apt-get -y install incus
sudo apt-get -y install incus incus-ui-canonical

sync

sudo adduser "$USER" incus-admin
newgrp incus-admin
