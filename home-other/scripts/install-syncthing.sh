#!/bin/bash


mkdir -p /etc/apt/keyrings

curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

apt update

apt install syncthing

sync

cp /lib/systemd/system/syncthing* /etc/systemd/system

systemctl daemon-reload
