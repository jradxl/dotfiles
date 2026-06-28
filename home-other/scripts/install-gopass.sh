#!/bin/bash

ARCH=$(arch)

case "$ARCH" in
  x86_64)
    ARCH=amd64
    ;;
  *)
    ARCH="$ARCH"
    ;;
esac

#source /etc/os-release
echo "Installing GOPASS for $ARCH"

curl https://packages.gopass.pw/repos/gopass/gopass-archive-keyring.gpg | sudo tee /usr/share/keyrings/gopass-archive-keyring.gpg >/dev/null
cat << EOF | sudo tee /etc/apt/sources.list.d/gopass.sources
Types: deb
URIs: https://packages.gopass.pw/repos/gopass
Suites: stable
Architectures: $ARCH
Components: main
Signed-By: /usr/share/keyrings/gopass-archive-keyring.gpg
EOF

echo ""

sudo apt update && sudo apt install -y gopass gopass-archive-keyring

exit 0
