#!/bin/bash
echo ""
echo "Installing Sublime Editor, will request SUDO password."
echo ""
if [[ $(command -v subl) ]]; then
    echo "Sublime-Text is already installed!"
else
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    sudo apt-get update
    sudo apt-get install sublime-text
fi

echo ""
echo "Executable is called: subl"
echo ""
echo "Finished"

