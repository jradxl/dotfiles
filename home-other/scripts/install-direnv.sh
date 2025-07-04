#!/bin/bash

if [[ ! $(command -v pipx) ]]; then
	echo "Pipx needs to be installed first. Run install_pipx.sh"
	exit 1
else
    if [[ ! $(command -v lastversion) ]]; then
	    echo "lastversion needs to be installed."
	    sudo pipx install --global lastversion
	    exit 1
    fi
fi

echo "Checking on DIRENV..."

# If installed from packages they are too old    
echo "Uninstalling DIRENV Ubuntu package if present as is too old."

if [[ $(dpkg -l direnv  2>/dev/null) ]]; then
    echo "Found DIRENV package installed, removing. Will require SUDO"
    sudo apt purge direnv -y  2>/dev/null >/dev/null
else
    echo "No DIRENV Ubuntu package installed."
fi

where_direnv=$(which direnv)
if [[ "$where_direnv" == "/usr/local/bin/direnv" ]]; then
    echo "DIRENV on path is correct."
else
    if [[ "$where_direnv" != ""  ]]; then
        echo "DIRENV on path is: $where_direnv"
        echo "Please remove and then re-run this script."
        exit 1
    fi
fi

if [[ $(command -v direnv) ]]; then
    echo "DIRENV already installed, checking for upgrade..."
    current_direnv="$(direnv --version)"
else
    echo "DIRENV not found, installing..."
    current_direnv=""
fi
echo "CURRENT: $current_direnv"
latest_direnv="$(lastversion https://github.com/direnv/direnv)"
echo "LATEST: $latest_direnv"

if [[ "$current_direnv" == "$latest_direnv" ]]; then
    echo "DIRENV already the latest version."
    exit 0
else
    echo "Installing or Upgrading direnv..."
fi

echo "installing DIRENV"
rm -rf /tmp/direnv*
# https://github.com/direnv/direnv/releases/download/v2.36.0/direnv.linux-amd64

##Found to be a redirect
( cd /tmp && curl -L -o /tmp/direnv  "https://github.com/direnv/direnv/releases/download/v$latest_direnv/direnv.linux-amd64" )
if [[ -f /tmp/direnv ]]; then
     ##sudo rm -f /usr/local/bin/
     sudo cp /tmp/direnv /usr/local/bin/
     sudo chown root:root /usr/local/bin/direnv
     sudo chmod +x /usr/local/bin/direnv
     hash -r
     direnv --version
else
    echo "Download failed."
fi
    
exit 0

echo "Removing modifications to .bashrc. PLEASE CHECK!"
sed -i '\|^# direnv Config:$|d'                          "$HOME/.bashrc"
sed -i '\|^source /home/jradley/.direnv/config.sh$|d'    "$HOME/.bashrc"
sed -i '\|^export PATH="$PATH:/home/jradley/.direnv"$|d' "$HOME/.bashrc"
echo "Done"

exit 0

