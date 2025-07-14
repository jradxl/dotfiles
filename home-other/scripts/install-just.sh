#!/bin/bash

#https://github.com/casey/just/releases/download/1.42.0/just-1.42.0-x86_64-unknown-linux-musl.tar.gz

echo "Installing or upgrading the Just"

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/casey/just)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

if [[ "$LATEST_VERSION" == "NO"  ]]; then
	echo "Not able to find latest version of JUST"
	exit 1
fi

CURRENT_VERSION=$(just --version | awk '{print $2}')

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

$(dpkg-query -W -f'${db:Status-Abbrev}\n' just 2>/dev/null | grep -q '^.i $')
RET=$?
if [[ "$RET" == "0" ]]; then
    echo 'Removing the apt installed version of JUST...'
    sudo apt purge -y just
fi

FILENAME="just-$LATEST_VERSION-x86_64-unknown-linux-musl.tar.gz"
URL="https://github.com/casey/just/releases/download/$LATEST_VERSION/just-$LATEST_VERSION-x86_64-unknown-linux-musl.tar.gz"
URLSHA="https://github.com/casey/just/releases/download/$LATEST_VERSION/SHA256SUMS"

$(cd /tmp && rm -f $(compgen -G "/tmp/just*") )
$(cd /tmp && wget "$URLSHA" )
$(cd /tmp && wget "$URL" )
$(cd /tmp && tar xf "$FILENAME")

pushd /tmp > /dev/null
shasum -a 256 -c /tmp/SHA256SUM
RET=$?
popd > /dev/null
RET="$?"
if [[ "$RET" == 0 ]]; then
        echo "Download checksum success"
        cp /tmp/just  "$HOME"/.local/bin
        mkdir -p "$HOME"/.local/share/man/man1
        cp /tmp/just.1 "$HOME"/.local/share/man/man1/
else
        echo "Download checksum fails."
        exit 1
fi

just --version
echo "RUN hash -r in your shell"

exit 0
