#!/bin/bash

echo "Installing or upgrading the Lazygit"

LATEST_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')

#if [[ $(command -v lastversion)  ]]; then
#	LATEST_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
#else
#	echo "Please ensure Pipx and Lastversion are installed"
#	exit 1
#fi

CURRENT_VERSION="NO"

if [[ $(command -v lazygit) ]]; then
    CURRENT_VERSION=$(lazygit --version | awk {'print $6'})
    CURRENT_VERSION=${CURRENT_VERSION#"version="}
    CURRENT_VERSION=${CURRENT_VERSION%","}
else
    CURRENT_VERSION="NO"
fi

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

URL="https://github.com/jesseduffield/lazygit/releases/download/v${LATEST_VERSION}/lazygit_${LATEST_VERSION}_Linux_x86_64.tar.gz"
(cd /tmp && curl -Lso lazygit.tar.gz "$URL")
(cd /tmp && tar xf lazygit.tar.gz lazygit)
install /tmp/lazygit -D -t "$HOME"/.local/bin/

echo "Installed Lazygit: $(lazygit --version | awk {'print $6'} | sed 's/.$//')"
echo "Done"

exit 0

