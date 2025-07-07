#!/bin/bash

echo "Installing or upgrading the Astral's UV"

### UV_NO_MODIFY_PATH=1 curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/0.7.19/uv-installer.sh | sh

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/astral-sh/uv)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

CURRENT_VERSION=$(uv --version | awk '/uv/ {print $2}')

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

UV_NO_MODIFY_PATH=1 curl --proto '=https' --tlsv1.2 -LsSf https://github.com/astral-sh/uv/releases/download/"$LATEST_VERSION"/uv-installer.sh | sh

echo ""

uv --version
echo "Done"

exit 0

