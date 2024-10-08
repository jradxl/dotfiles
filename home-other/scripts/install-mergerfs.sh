#!/bin/bash
echo "Installing MERGERFS..."

if [[ ! $(command -v pipx) ]]; then
	echo "Pipx needs to be installed first. Run install_pipx.sh"
	exit 1
fi

if [[ ! $(command -v lastversion) ]]; then
	echo "lastversion needs to be installed."
	sudo pipx install --global lastversion
	exit 1
fi

# If installed from packages they are too old    
echo "Uninstalling mergerfs Ubuntu package if present as is too old."
sudo apt purge mergerfs -y  2>/dev/null >/dev/null

LATEST_VERSION=$(lastversion https://github.com/trapexit/mergerfs)
echo "LATEST VERSION: $LATEST_VERSION"
CURRENT_VERSION="NONE"
if [[ $(command -v  mergerfs) ]]; then
    CURRENT_VERSION=$(sudo mergerfs --version  | grep "mergerfs v"  | awk '/mergerfs/ {print $2}')
    CURRENT_VERSION="${CURRENT_VERSION:1}"
fi
echo "CURRENT VERSION: $CURRENT_VERSION"

if [[  "$LATEST_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "MERGERFS is already the latest version"
else
    echo "installing MERGERFS"
    rm -rf /tmp/mergerfs*
    ( cd /tmp && wget https://github.com/trapexit/mergerfs/releases/download/"$LATEST_VERSION"/mergerfs-static-linux_amd64.tar.gz )
    if [[ -f /tmp/mergerfs-static-linux_amd64.tar.gz ]]; then
         sudo tar xf  /tmp/mergerfs-static-linux_amd64.tar.gz  -C /
         hash -r
         sudo mergerfs --version  | grep "mergerfs v"
    fi
fi
echo "DONE"
exit 0

