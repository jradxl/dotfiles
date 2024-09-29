#!/bin/bash

#I don't like the installer
# curl -fsSL https://deno.land/install.sh | sh
#So I have my own

#URL https://github.com/denoland/deno/releases/download/v1.46.3/deno-x86_64-unknown-linux-gnu.zip
#URL https://dl.deno.land/release/v2.0.0-rc.7/deno-x86_64-unknown-linux-gnu.zip

echo "Installing or upgrading Deno"

mkdir -p "$HOME"/.deno/bin

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/denoland/deno)
else
	echo "Please ensure Pipx and Lastversion are installed."
	exit 1
fi

CURRENT_VERSION=""
if [[ $(command -v deno) ]]; then
    CURRENT_VERSION=$(deno --version | awk '/deno/ {print $2}')
fi

FILENAME="deno-x86_64-unknown-linux-gnu.zip"
URL_BASE="https://github.com/denoland/deno/releases/download/v1.46.3"
URL="$URL_BASE/$FILENAME"

echo "CURRENT Deno: $CURRENT_VERSION"
echo "LATEST Deno:  $LATEST_VERSION"

if [[ $CURRENT_VERSION == "2.0.0-rc.7" ]]; then
    echo "Version 2 RC installed. Aborting"
    exit 1
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Deno is already the latest version."
	exit 0
else
    echo "Installing Deno Version $LATEST_VERSION ..." 
    rm -rf /tmp/deno*
    (cd /tmp && wget "$URL")
    (cd /tmp && unzip "$FILENAME")
    if [[ -x /tmp/deno ]]; then
        mv /tmp/deno "$HOME"/.deno/bin
    else
        echo "Error: Deno not found"
        exit 1
    fi
    hash -r
fi

echo "Deno installed. Reopen shell to ensure path set."
exit 0

