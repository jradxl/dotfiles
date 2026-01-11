#!/bin/bash

# wget https://github.com/zyedidia/micro/releases/download/v2.0.15/micro-2.0.15-linux64.tar.gz
# wget https://github.com/zyedidia/micro/releases/download/v2.0.15/micro-2.0.15-linux64-static.tar.gz
# wget https://github.com/zyedidia/micro/releases/download/v2.0.15/micro-2.0.15-linux64-static.tar.gz.sha
# gmcr="$(curl https://getmic.ro)" && [ $(echo "$gmcr" | shasum -a 256 | cut -d' ' -f1) = 45e188ef0d5300cb04dcdece3934fa92f47b7581125c615a8bfae33ac7667a16 ] && echo "$gmcr" | sh

echo "Installing or upgrading the Micro Editor"

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/zyedidia/micro)
	#Returns eg, 2.0.15
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

if [[ "$LATEST_VERSION" == "NO"  ]]; then
	echo "Not able to find latest version of micro"
	exit 1
fi

CURRENT_VERSION=$(micro --version | awk '/Version/ {print $2}')
# Returns e.g 2.0.14

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

$(dpkg-query -W -f'${db:Status-Abbrev}\n' micro 2>/dev/null | grep -q '^.i $')
RET=$?
if [[ "$RET" == "0" ]]; then
    echo 'Removing the apt installed version of micro...'
    sudo apt purge -y micro
fi

FILENAME="micro-$LATEST_VERSION-linux64-static.tar.gz"
URL="https://github.com/zyedidia/micro/releases/download/v$LATEST_VERSION/$FILENAME"

$(cd /tmp && rm -f $(compgen -G "/tmp/micro*") )
$(cd /tmp && wget "$URL".sha )
$(cd /tmp && wget "$URL" )
pushd /tmp > /dev/null
shasum -a 256 -c "$FILENAME".sha
RET=$?
popd > /dev/null

if [[ "$RET" == 0 ]]; then
	echo "Download checksum success"
	$(cd /tmp && tar xf "$FILENAME")
	#sudo cp /tmp/micro-"$LATEST_VERSION"/micro /usr/local/bin
	cp /tmp/micro-"$LATEST_VERSION"/micro "$HOME"/.local/bin
else
	echo "Download checksum fails."
	exit 1
fi

micro --version
echo "RUN hash -r in your shell"

exit 0

