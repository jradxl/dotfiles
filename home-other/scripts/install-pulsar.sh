#!/bin/bash

echo "Installing Pulsar Editor (as in Atom)"

CURRENT_VERSION="None"
if [[ $(command -v pulsar) ]]; then
    echo "Aleady Installed. Checking version..."
    CURRENT_VERSION=$(pulsar --version | grep Pulsar | awk '{ print $3 }' )
    echo "Current Version: $CURRENT_VERSION"
else
    echo "Not installed"
fi

LATEST_VERSION=$(lastversion https://github.com/pulsar-edit/pulsar)
echo "Latest Version: $LATEST_VERSION"

LATEST_FILE="Linux.pulsar_"$LATEST_VERSION"_amd64.deb"

INSTALL="NO"
if [[ "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "Already the latest version."
else
    INSTALL="YES"
    echo "Installing or upgrading to the latest version."
fi

if [[ "$INSTALL" == "YES" ]]; then
    URL="https://github.com/pulsar-edit/pulsar/releases/download/v"$LATEST_VERSION"/"$LATEST_FILE""
    (cd /tmp && rm -f *.deb)
    (cd /tmp && wget "$URL")
    sudo apt-get install -y /tmp/"$LATEST_FILE"
fi

