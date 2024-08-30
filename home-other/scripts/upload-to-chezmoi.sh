#!/bin/bash

if [[ $(command -v rsync) ]]; then
    echo "Updating local script files to CHEZMOI Repo"
    rsync --progress -rutp $HOME/scripts/* $HOME/.local/share/chezmoi/home-other/scripts
else
    echo "RSYNC is not installed."
fi

rm "$HOME/.local/share/chezmoi/home-other/scripts/"*bak1
exit 0

