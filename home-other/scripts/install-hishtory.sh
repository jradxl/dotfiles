#!/bin/bash

echo "Checking on HISHTORY..."

if [[ $(command -v hishtory) ]]; then
    echo "HISHTORY already installed, checking for upgrade..."
    current_hishtory="$(hishtory --version | awk '{print $3}')"
    echo "CURRENT: $current_hishtory"
else
    echo "HISHTORY not found, installing..."
    current_hishtory=""
fi

latest_hishtory="v$(lastversion https://github.com/ddworken/hishtory)"
echo "LATEST: $latest_hishtory"

if [[ "$current_hishtory" == "$latest_hishtory" ]]; then
    echo "HISHTORY already the latest version."
    exit 0
else
    echo "Installing or Upgrading HISHTORY..."
fi

curl https://hishtory.dev/install.py | python3 -
echo "<$?>"

echo "Removing modifications to .bashrc. PLEASE CHECK!"
sed -i '\|^# Hishtory Config:$|d'                          "$HOME/.bashrc"
sed -i '\|^source /home/jradley/.hishtory/config.sh$|d'    "$HOME/.bashrc"
sed -i '\|^export PATH="$PATH:/home/jradley/.hishtory"$|d' "$HOME/.bashrc"
echo "Done"

exit 0

