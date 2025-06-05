#!/bin/bash

VAR1=$(curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint)

VAR2=$(cat <<EOF
pub   rsa3072 2023-08-23 [SC] [expires: 2025-08-22]
      4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD
uid                      Zabbly Kernel Builds <info@zabbly.com>
sub   rsa3072 2023-08-23 [E] [expires: 2025-08-22]
EOF
)

if [[ "$VAR1" == "$VAR2" ]]; then
    echo "Zabbly Certificate OK"
    echo "Installing INCUS. Needs SUDO password."
else
    echo "Zabbly Certificate Fails"
    exit 1
fi

sudo mkdir -p /etc/apt/keyrings/

sudo curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc

#> /etc/apt/sources.list.d/zabbly-incus-stable.sources

VAR3=$(cat <<EOF 
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc
EOF
)

echo "$VAR3" | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.sources

sudo apt-get update

sudo apt-get -y install incus incus-ui-canonical

exit 0

