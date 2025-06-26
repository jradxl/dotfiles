#!/bin/bash

echo "Installing the N3N VPN Software"

GITREPO="https://github.com/n42n/n3n.git"
REPODEST="$HOME/Devel/n3n"
STATE=""
CWD=$(pwd)

echo "Installing dependancies..."
sudo apt-get -q -y update &&
sudo apt-get -q -y upgrade &&
sudo apt-get install -y -q git autoconf

if [[ $(command -v n3n-edge) ]]; then
    echo "N3N already installed"
else
    echo "N3N not installed. Cloning the Git repository..."
    STATE="INSTALL"
    mkdir -p "$REPODEST"
    cd "$REPODEST"
    git clone "$GITREPO"
    cd n3n
    "$REPODEST"/n3n/autogen.sh
    "$REPODEST"/n3n/configure
    make
    sudo make install

    sudo cp /usr/local/lib/systemd/system/n3n-edge.service /etc/systemd/system
    sudo cp /usr/local/lib/systemd/system/n3n-supernode.service /etc/systemd/system
fi

echo ""

URL=${GITREPO%.*}
LATEST=v$(lastversion "$URL")
echo "Latest Version: $LATEST"

CURRENT=$(n3n-edge -V | grep n3n | awk '{print $2}')
arr=(${CURRENT//-/ })
CURRENT=${arr[0]}
echo "Current Version $CURRENT"

if [[ "$CURRENT" == "$LATEST" ]]; then
    echo "N3N is already the latest version"
else
    echo "N3N needs an upgrade"
fi
