#!/bin/bash

mkdir -p "$HOME/scripts/" 

if [[ $(command -v rsync) ]]; then

    echo "Deploying Scripts from CHEZMOI Repo to $HOME/scripts"
    #OLD rsync --progress -rutp "$HOME/scripts/"*.sh "$HOME/.local/share/chezmoi/home-other/scripts"
    
    rsync --progress -rutp "$HOME/.local/share/chezmoi/home-other/scripts"/*.sh  "$HOME/scripts/" 
    
else
    echo "RSYNC is not installed."
fi

# rm -f "$HOME/.local/share/chezmoi/home-other/scripts/"*bak1

exit 0

