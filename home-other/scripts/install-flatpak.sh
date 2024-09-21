#!/bin/bash

#This does not work for Flatpak
function get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" |  grep -v "pre" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }'; }

if [[ $(command -v pipx) ]]; then
    echo "Good. PIPX is installed"
else
    echo "Please install PIPX first. See 'install-pipx.sh'"
    exit 1
fi

if [[ $(command -v lastversion) ]]; then
    echo "Good. LASTVERSION is installed"
else
    echo "Installing LASTVERSION using PIPX"
    sudo pipx install --global lastversion
fi

FLATPAK_INSTALLED=$(flatpak --version)
FLATPAK_LATEST=$(lastversion https://github.com/flatpak/flatpak)

echo "INSTALLED: $FLATPAK_INSTALLED"
echo "LATEST: $FLATPAK_LATEST"

if [[ "$FLATPAK_INSTALLED" == "$FLATPAK_LATEST" ]]; then
    echo "No FLATPAK upgrade needed."
else
     echo "A FLATPAK upgrade is needed."
     echo "Installing the PPA for Flatpak if needed."
     sudo add-apt-repository -y ppa:flatpak/stable
     sudo apt-get update -y
     sudo apt-get install -y flatpak
fi

echo "Flatpak Version installed is: $(flatpak --version)"

echo "Adding FLATHUB if not already..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Use SUDO when installing system packages 'sudo flatpak install --system com.google.Chrome'"
exit 0

