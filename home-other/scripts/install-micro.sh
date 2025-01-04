#!/bin/bash

# wget https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linux64-static.tgz.sha
# wget https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linux64-static.tgz
# gmcr="$(curl https://getmic.ro)" && [ $(echo "$gmcr" | shasum -a 256 | cut -d' ' -f1) = 45e188ef0d5300cb04dcdece3934fa92f47b7581125c615a8bfae33ac7667a16 ] && echo "$gmcr" | sh

echo "Installing or upgrading the Micro Editor"

LATEST_VERSION="NO"

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/zyedidia/micro)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

CURRENT_VERSION=$(micro --version | awk '/Version/ {print $2}')

echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

FILENAME="micro-$LATEST_VERSION-linux64-static.tgz"
URL="https://github.com/zyedidia/micro/releases/download/v$LATEST_VERSION/$FILENAME"

if [[ "$LATEST_VERSION" == "NO"  ]]; then
	echo "Not able to find latest version of micro"
	exit 1
fi

$(cd /tmp && rm -rf micro* )
$(cd /tmp && wget "$URL".sha )
$(cd /tmp && wget "$URL" )
pushd /tmp > /dev/null
#Odd usage of shasum. Won't take absolute path, and won't work within $()
shasum -a 256 -c "$FILENAME".sha
RET=$?
popd > /dev/null

if [[ "$RET" == 0 ]]; then
	echo "Download checksum success"
	$(cd /tmp && tar xf "$FILENAME")
	sudo cp /tmp/micro-"$LATEST_VERSION"/micro /usr/local/bin
else
	echo "Download checksum fails."
	exit 1
fi

micro --version
echo "RUN hash -r in your shell"

exit 0
