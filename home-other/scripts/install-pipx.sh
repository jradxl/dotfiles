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
	PIPXURL="https://github.com/pypa/pipx/releases/download/$PIPXLATESTVER/pipx.pyz"
	sudo wget -O /usr/local/bin/pipx $PIPXURL
	sudo chmod +x /usr/local/bin/pipx
fi
echo "Installed Pipx is: $(pipx --version)"
echo "IMPORTANT: Due to a bug use like, 'sudo pipx install --global <package>'"
exit 0
