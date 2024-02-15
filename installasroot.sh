#!/usr/bin/env bash

#set -eu

#Download this file using the following URL:
#  curl -fsSl https://raw.githubusercontent.com/jradxl/dotfiles/main/installasroot.sh > install.sh
#  chmod +x install.sh
# ./install.sh

PUBLICKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3YXTN6G2zLiwneZgtlPsAAg1uwj8OcB3vVmph4paM2"

# IMPORTANT
#Not stored in Git Repo. Add manually before running.
TAILSCALEAUTHKEY="Empty"

if [[ "$(id -u)" != "0" ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ "$TAILSCALEAUTHKEY" == "Empty" ]]; then
   echo "Edit this script to add a Tailscale Auth Key before running." 1>&2
   exit 1
fi

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
        htop glances btop keychain jq python3-venv python3-pip net-tools dirmngr gnupg \
        gawk bridge-utils smartmontools

if [[ "$LOCATION" == "desktop" ]]; then
  echo "Installing for Desktop..."
  apt-get --no-install-recommends --quiet --yes install  terminator gparted libgtk-3-dev \
          chromium-browser firefox gsmartcontrol
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
adduser "$username" sudo || echo "Already present."

if [[ ! $(which tailscale) ]]; then
  echo "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
 echo "Tailscale already installed."
fi

if [[ $(tailscale status | grep "Logged" ) ]]; then
    echo "Activating Tailscale with Auth Key"
    tailscale up --auth-key "$TAILSCALEAUTHKEY"
    tailscale status
else
  echo "Tailscale is up"
fi

exit 0

