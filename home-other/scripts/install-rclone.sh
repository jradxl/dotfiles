#!/bin/bash

echo "Installing RCLONE"

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
if [[ $(command -v rclone) ]]; then
    echo "Aleady Installed. Checking version..."
    CURRENT_VERSION=$(rclone --version | grep rclone | awk '{ print $2 }' )
    CURRENT_VERSION="${CURRENT_VERSION:1}"
    echo "RCLONE Current Version: $CURRENT_VERSION"
else
    echo "RCLONE is Not installed"
fi

LATEST_VERSION=$(lastversion  https://github.com/rclone/rclone)
echo "Latest Version: $LATEST_VERSION"

INSTALL="NO"
if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "Already the latest version."
else
    INSTALL="YES"
    echo "Installing or upgrading to the latest version."
fi

if [[ "$INSTALL" == "YES" ]]; then
    sudo -v ; curl https://rclone.org/install.sh | sudo bash
fi
echo "RCLONE installed with version ..."
echo "<$(rclone --version)>"

exit 0

