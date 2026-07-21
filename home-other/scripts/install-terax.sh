#!/bin/bash

echo "Installing Latest version of TERAX..."

URL=$(curl -s https://api.github.com/repos/crynta/terax-ai/releases | jq '.[0].assets[].browser_download_url'  | grep ".deb" | head -n 1 | tr -d '"')
echo "URL: $URL"

rm -f $(compgen -G "/tmp/Terax*")
log_file="/tmp/Teraxfile.txt"
(cd /tmp && wget -o $log_file $URL)
FILE=$(sed -En 's/^Saving to: ‘(.+)’/\1/p' $log_file)
echo "FILENAME DOWNLOADED: $FILE"

if [[ -f "/tmp/$FILE" ]]; then
    echo "Installing Terax Deb File..."
    sudo apt-get install -y "/tmp/$FILE"
fi

exit 0

