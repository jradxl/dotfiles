#!/bin/bash

echo "Installing Netbird, in favour of Tailscale"

sudo apt-get purge -y tailscale* ^iptables*

sudo tee /etc/apt//preferences.d/iptables.pref << EOF > /dev/null
Package: iptables:any
Pin: release *
Pin-Priority: -1
EOF

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
curl -sSL https://pkgs.netbird.io/debian/public.key | sudo gpg --dearmor --output /usr/share/keyrings/netbird-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' | sudo tee /etc/apt/sources.list.d/netbird.list

sudo apt-get update && sudo apt-get install netbird

netbird status

exit 0


