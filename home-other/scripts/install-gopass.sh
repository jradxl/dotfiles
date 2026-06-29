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
echo "Installing PASS and GOPASS for $ARCH"

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
sudo apt-get update -y

echo "Installing GPG, GPG-AGENT and PINENTRY-TTY..."
sudo apt-get install -y gpg gpg-agent pinentry-tty

echo "Installing GOPASS"
sudo apt-get install -y gopass gopass-archive-keyring

mkdir  -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
#gpg.conf
cat << EOF | tee "$HOME/.gnupg"
pinentry-mode loopback
EOF

#gpg-agent.conf 
cat << EOF | tee "$HOME/.gnupg"
#pinentry-program /usr/bin/pinentry-curses
pinentry-program /usr/bin/pinentry-tty
allow-loopback-pinentry
EOF

gpg --list-keys
gpg -K

exit 0
