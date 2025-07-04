#!/bin/bash

# If installed from packages it is too old. 
sudo apt-get -y purge pipx 2>/dev/null >/dev/null 

#Correct VENV package is needed
sudo apt-get -y install python3-venv 2>/dev/null >/dev/null

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

PIPXLATESTVER=$(get-github-latest https://github.com/pypa/pipx.git)

## If Pipx is in this location, then it has been installed correctly. Perhaps by us previously??
if [[ $(sudo ls /usr/local/bin/pipx 2>/dev/null) ]]; then
	echo "Pipx is already installed."
	PIPXVER=$(pipx --version)
	echo "Installed version of PIPX is: $PIPXVER"
	echo "Latest version of PIPX is: $PIPXLATESTVER"
	if [[ "$PIPXLATESTVER" == "$PIPXVER" ]]; then
		echo "Installed version of Pipx is latest"
		PIPX_INSTALL="NO"
	else
		echo "Pipx needs an upgrade."
		PIPX_INSTALL="YES"
	fi
else
	echo "Pipx not installed"
	PIPX_INSTALL="YES"
fi

if [[ "$PIPX_INSTALL" == "YES"  ]]; then
	echo "Installing or upgrading Pipx"
	sudo apt purge pipx
	sudo apt install wget
	PIPXURL="https://github.com/pypa/pipx/releases/download/$PIPXLATESTVER/pipx.pyz"
	sudo wget -O /usr/local/bin/pipx $PIPXURL
	sudo chmod +x /usr/local/bin/pipx
	hash -r
fi
echo "Installed Pipx is: $(pipx --version)"
echo "IMPORTANT: Due to a bug: Use like this, 'sudo pipx install --global <package>'"

hash -r

echo "Now installing LASTVERSION..."
VERSION=""
if [[ $(command -v lastversion) ]]; then
	VERSION=$(pipx list --global | grep lastversion | grep package| awk '{print $3}')
	VERSION="${VERSION//,}"
fi

if [[ -z "$VERSION" ]]; then
    echo "Installing LASTVERSION"
    sudo pipx install --global lastversion
else
    echo "LASTVERSION already installed. Trying to upgrade..."
    sudo pipx upgrade --global lastversion
fi
lastversion --version
exit 0

