#!/usr/bin/bash

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: incus-initial.sh <container> <username>"
    exit 1
fi
incus exec "$1" -- bash -c "apt update -y"
incus exec "$1" -- bash -c "apt upgrade -y"
incus exec "$1" -- bash -c "apt autoremove -y"
incus exec "$1" -- bash -c "apt install -y sudo whois openssh-server"
incus exec "$1" -- bash -c "useradd -m $2 -s /bin/bash -Gsudo"
incus exec "$1" -- bash -c "passwd $2"

exit 0

