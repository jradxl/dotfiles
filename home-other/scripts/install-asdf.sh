#!/bin/bash

##Check and upgrade ASDF Version Manager

##Dependancies: PIPX and LASTVERSION
## apt install pipx if latest
## pipx install lastversion
## then add PATH

ASDF_HOME="$HOME/bin"

if command -v lastversion > /dev/null 2>&1 ; then
    echo "OK, Lastversion is installed."
else
    echo "Lastversion not installed."
    exit 1
fi

#Prepend a 'v' for later compare
latest="v"$(lastversion https://github.com/asdf-vm/asdf)
echo "Latest ASDF is: ${latest}"

if command -v asdf > /dev/null 2>&1 ; then
    current=$(asdf --version | awk '{print $3}')
    echo "Current ASDF is: ${current}"
else
    echo "ASDF is not installed"
    current=""
fi

if [[ ${current} == "${latest}" ]]; then
	echo "ASDF is the latest version"
else
	echo "Installing/Upgrading ASDF..."
	rm -rf "$ASDF_HOME/asdf-${latest}-linux-amd64.tar.gz"
	## https://github.com/asdf-vm/asdf/releases/download/v0.20.2/asdf-v0.20.2-linux-amd64.tar.gz
	mkdir -p "$ASDF_HOME"
	wget https://github.com/asdf-vm/asdf/releases/download/"${latest}"/asdf-${latest}-linux-amd64.tar.gz -P "$HOME/bin"
	tar xf "$ASDF_HOME"/asdf-${latest}-linux-amd64.tar.gz -C "$ASDF_HOME"
	rm -rf "$ASDF_HOME/asdf-${latest}-linux-amd64.tar.gz"
	echo "ASDF installed to: $(command -v asdf)"
fi

