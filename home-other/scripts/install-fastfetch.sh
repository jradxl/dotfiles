#!/bin/bash

echo "Installing FastFetch"

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }'; }

if [[ $(command -v pipx) ]]; then
    echo "PIPX is installed. Checking version"
    PIPX_VERSION=$(pipx --version)
    echo "Installed version: $PIPX_VERSION"
    AAA=$(version $PIPX_VERSION)
    BBB=$(version 1.7.1)  
    if [[ $AAA -ge $BBB ]]; then
        echo "PIPX version is OK."
    else
        echo "PIPX is out of date. Please run 'install-pipx.sh' first"
        exit 1
    fi
else
    echo "Please install PIPX first. See 'install-pipx.sh'"
    exit 1
fi

if [[ $(command -v lastversion) ]]; then
    echo "Good. LASTVERSION is installed"
else
    echo "Installing LASTVERSION using PIPX"
    sudo pipx install --global lastversion
fi

CURRENT_VERSION="None"
if [[ $(command -v fastfetch) ]]; then
    echo "Aleady Installed. Checking version..."
    CURRENT_VERSION=$(fastfetch --version | awk '{ print $2 }' )
    echo "Fastfetch Current Version: $CURRENT_VERSION"
else
    echo "Fastfetch is Not installed"
fi

LATEST_VERSION=$(lastversion https://github.com/fastfetch-cli/fastfetch)
echo "Latest Version: $LATEST_VERSION"

LATEST_FILE="fastfetch-linux-amd64.deb"

INSTALL="NO"
if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "Already the latest version."
else
    INSTALL="YES"
    echo "Installing or upgrading to the latest version."
fi

if [[ "$INSTALL" == "YES" ]]; then
    URL="https://github.com/fastfetch-cli/fastfetch/releases/download/$LATEST_VERSION/$LATEST_FILE"
    (cd /tmp && rm -f *.deb)
    (cd /tmp && wget "$URL")
    sudo apt-get install -y /tmp/"$LATEST_FILE"
fi
echo "Fastfetch installed. Version"
echo "<$(fastfetch --version)>"

exit 0

