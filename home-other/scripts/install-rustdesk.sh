#!/bin/bash

## URI: https://github.com/rustdesk/rustdesk/releases/download/1.3.0/rustdesk-1.3.0-x86_64.deb

#Gets Nightly
get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" |  tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

echo "Rustdesk installer."

if [[ $(command -v pipx) ]]; then
    echo "Good. PIPX is installed"
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

echo "Getting latest version..."

RUSTDESK_LATEST_VERSION=$(lastversion  https://github.com/rustdesk/rustdesk)
echo "Rustdesk latest version is: $RUSTDESK_LATEST_VERSION"

INSTALL="NO"
if [[ $(command -v rustdesk) ]]; then
	RUSTDESK_INSTALLED_VERSION=$(rustdesk --version)
	echo "Rustdesk is installed with version: $RUSTDESK_INSTALLED_VERSION"
	if [[ $RUSTDESK_INSTALLED_VERSION  != $RUSTDESK_LATEST_VERSION ]]; then
		echo "Rustdesk is out of date."
		INSTALL="YES"
    else
    	echo "No update is necessary."
	fi
else
	echo "Rustdesk is not installed."
	INSTALL="YES"
fi

if [[ $INSTALL == "YES" ]]; then
	echo "Downloading and installing latest Rustdesk..."
    ( cd /tmp && rm -f rustdesk* )	
	URI=" https://github.com/rustdesk/rustdesk/releases/download/$RUSTDESK_LATEST_VERSION/rustdesk-$RUSTDESK_LATEST_VERSION-x86_64.deb"
	echo "Download URI is: $URI"
	( cd /tmp && wget -q $URI )
	( cd /tmp && sudo apt install -y ./rustdesk-$RUSTDESK_LATEST_VERSION-x86_64.deb)
fi

exit 0
