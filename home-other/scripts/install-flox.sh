#!/bin/bash

#https://downloads.flox.dev/by-env/stable/deb/flox-1.3.12.x86_64-linux.deb

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

echo "Installing FLOX package manager..."

FLOX_LATEST=$(get-github-latest https://github.com/flox/flox)
echo "FLOX latest is: $FLOX_LATEST"
FLOX_LATEST=${FLOX_LATEST:1:6}

FLOX_CURRENT=""
if [[ $(command -v flox) ]]; then
    FLOX_CURRENT=$(flox --version)
else
    echo "FLOX is not installed"
fi

if [[ $FLOX_LATEST == $FLOX_CURRENT ]]; then
    echo "FLOX is already installed as version: $FLOX_CURRENT"
else
    echo "Installing FLOX version $FLOX_LATEST"
    FILE="flox-$FLOX_LATEST.x86_64-linux.deb"
    URL="https://downloads.flox.dev/by-env/stable/deb/$FILE"
    ( cd /tmp && wget "$URL" )
    ( cd /tmp && sudo apt install -y ./"$FILE" )
    ( cd /tmp && rm -rf "$FILE" )
fi

if [[ $(command -v nix) ]]; then
    echo "NIX Package manager is installed at version: $(nix --version)"
    echo "NIX DAEMON: $(systemctl list-units -q nix-daemon.service)"
fi

