#!/bin/bash

## URL:  https://github.com/pnpm/pnpm/releases/download/v9.12.0/pnpm-linuxstatic-x64

#I don't like the installer
# wget -qO- https://get.pnpm.io/install.sh | sh -
#So I have my own

echo "Installing PNPM..."

LATEST_VERSION="NO"
if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/pnpm/pnpm)
else
	echo "Please ensure Pipx and Lastversion are installed."
	exit 1
fi

CURRENT_VERSION=""
if [[ $(command -v pnpm) ]]; then
    CURRENT_VERSION=$(pnpm --version)
fi

BASE_URL="https://github.com/pnpm/pnpm/releases/download/v$LATEST_VERSION"
FILENAME="pnpm-linuxstatic-x64"
FULL_URL="$BASE_URL/$FILENAME"

#echo "$FULL_URL"
echo "CURRENT VERSION: $CURRENT_VERSION"
echo "LATEST VERSION: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "PNPM is already the latest version."
	exit 0
else
    echo "Installing PNPM Version $LATEST_VERSION ..." 
    rm -rf /tmp/pnpm*
    (cd /tmp && wget "$FULL_URL")
    if [[ -f /tmp/pnpm-linuxstatic-x64 ]]; then
    	mv /tmp/pnpm-linuxstatic-x64 /tmp/pnpm
    	chmod +x /tmp/pnpm
    	mkdir -p "$HOME"/.local/share/pnpm/
        mv /tmp/pnpm "$HOME"/.local/share/pnpm/
    else
        echo "Error: PNPM not found"
        exit 1
    fi
    hash -r
fi
echo "Done installing PNPM v$LATEST_VERSION"
exit 0

