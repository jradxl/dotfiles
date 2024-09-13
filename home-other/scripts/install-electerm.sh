#!/bin/bash

# ELECTERM #
# See https://github.com/electerm/electerm

echo "Installer for a deb version of Electerm"
echo ""
# URL "https://github.com/electerm/electerm/releases/download/v1.39.119/electerm-1.39.119-linux-amd64.deb"

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" |  tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

ARCH=$(dpkg --print-architecture)
echo "Current Architecture is: $ARCH"

LATEST_VERSION1=$(get-github-latest https://github.com/electerm/electerm)
LATEST_VERSION2="${LATEST_VERSION1/v}"
echo "Latest Version of Electerm is: $LATEST_VERSION1 : $LATEST_VERSION2"

FILE_NAME1="electerm-$LATEST_VERSION2.linux-$ARCH.tar.gz"
FILE_NAME2="electerm-$LATEST_VERSION2.linux-$ARCH"

echo "Filenames are: $FILE_NAME1 : $FILE_NAME2"
echo ""

#Clean any previous runs
(cd /tmp && rm -rf electerm* )

#Download
(wget --directory-prefix=/tmp  "https://github.com/electerm/electerm/releases/download/$LATEST_VERSION1/electerm-$LATEST_VERSION2-linux-$ARCH.deb" )
if [[ $? -ne 0  ]]; then
    echo "Download Error: Exiting"
    exit 1
fi

if [[ -f "/tmp/electerm-$LATEST_VERSION2-linux-$ARCH.deb" ]]; then
    sudo apt install -y "/tmp/electerm-$LATEST_VERSION2-linux-$ARCH.deb"
else
    "Can't find file."
fi

echo "Finished."
exit 0

