#!/usr/bin/env bash

PUBLICKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3YXTN6G2zLiwneZgtlPsAAg1uwj8OcB3vVmph4paM2"

echo "Installing..."
touch /root/.ssh/authorized_keys
$(grep -Fxq "$PUBLICKEY" /root/.ssh/authorized_keys)
if [[  "$?" -eq 1 ]]; then
    echo "$PUBLICKEY" >> /root/.ssh/authorized_keys
fi

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive
## Questions that you really, really need to see (or else). ##
export DEBIAN_PRIORITY=critical
apt-get -qy clean
apt-get -qy update
apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade

apt-get --no-install-recommends --quiet --yes install apt-utils

function isDesktopOrServer() {
    dpkg -l | grep desktop > /dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        LOCATION="desktop"
        #echo "desktop"
    else
        LOCATION="server"
        #echo "server"
    fi
}

isDesktopOrServer

##Install packages common to both Server and Desktop
apt-get --no-install-recommends --quiet --yes install curl wget openssh-server \
        git mtools btrfs-progs build-essential libxt-dev libpython3-dev libncurses-dev \
        htop glances btop keychain


if [[ "$LOCATION" == "desktop" ]]; then
  echo "Installing for Desktop..."
  apt-get --no-install-recommends --quiet --yes install  terminator gparted libgtk-3-dev \
          chromium-browser firefox
fi

#if [[ "$LOCATION" == "server" ]]; then
#  echo "Installing for Server..."
#  apt-get --no-install-recommends --quiet --yes install  curl wget openssh-server
#fi

snap refresh lxd --channel=latest


username=jovyan
password=jovyan
adduser --gecos "" --disabled-password "$username"
chpasswd <<<"$username:$password"
adduser "$username" sudo
