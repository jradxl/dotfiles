#!/bin/bash

echo "Installing or upgrading the NEOVIM"

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=v$(lastversion https://github.com/neovim/neovim)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

if [[ "$LATEST_VERSION" == "NO"  ]]; then
	echo "Not able to find latest version of NEOVIM"
	exit 1
fi

CURRENT_VERSION=$(nvim -v | grep NVIM | awk '{print $2}')

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

$(dpkg-query -W -f'${db:Status-Abbrev}\n' neovim 2>/dev/null | grep -q '^.i $')
RET=$?
if [[ "$RET" == "0" ]]; then
    echo 'Removing the apt installed version of NEOVIM...'
    sudo apt purge -y neovim
    sudo apt autoremove -y
fi

TARFILE="nvim-linux-x86_64.tar.gz"
URL="https://github.com/neovim/neovim/releases/latest/download/$TARFILE"
FILENAME="nvim-linux-x86_64"

$(cd /tmp && rm -rf $(compgen -G "/tmp/nvim*") )
$(cd /tmp && curl -LO "$URL" )
$(cd /tmp && tar xf "$TARFILE")
mkdir -p "$HOME"/Apps/
cp -r /tmp/"$FILENAME" "$HOME/Apps/"
rm -rf "$HOME/Apps/nvim"
mv "$HOME/Apps/$FILENAME" "$HOME/Apps/nvim"

nvim -v
echo "RUN hash -r in your shell"

exit 0

