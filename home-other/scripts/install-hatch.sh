#!/bin/bash

## https://github.com/pypa/hatch/releases/download/hatch-v1.14.1/hatch-x86_64-unknown-linux-gnu.tar.gz

echo "Installing or upgrading the HATCH"

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/pypa/hatch)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

CURRENT_VERSION=$(hatch --version | awk '/Hatch/ {print $3}')

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

##hatch-x86_64-unknown-linux-gnu.tar.gz
FILENAME="hatch-x86_64-unknown-linux-gnu.tar.gz"
URL="https://github.com/pypa/hatch/releases/download/hatch-v$LATEST_VERSION/hatch-x86_64-unknown-linux-gnu.tar.gz"

if [[ "$LATEST_VERSION" == "NO"  ]]; then
	echo "Not able to find latest version of micro"
	exit 1
fi

$(cd /tmp && rm -f $(compgen -G "/tmp/hatch*") )
$(cd /tmp && wget "$URL" )

if [[ -f /tmp/"$FILENAME"  ]]; then
	echo "Download success"
	$(cd /tmp && tar xf "$FILENAME")
	cp /tmp/hatch "$HOME"/.local/bin
else
	echo "Download failed."
	exit 1
fi

hatch --version
echo "RUN hash -r in your shell"

exit 0

