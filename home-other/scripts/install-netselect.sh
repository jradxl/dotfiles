#!/bin/bash

echo ""
echo "Find fastest top 10 Ubuntu Mirrors..."
echo ""
echo "    Will ask for SUDO password..."
echo ""

ARCH=$(dpkg --print-architecture)
VERSION="0.3.ds1-30.1"
FILE="netselect_${VERSION}_${ARCH}.deb"
URL="http://ftp.debian.org/debian/pool/main/n/netselect/$FILE"

#echo "$URL"

echo "    Will install $VERSION from Debian Archives... Check that this is latest."
echo ""

if [[ -f "/tmp/$FILE" ]]; then
    rm -rf "/tmp/$FILE"
fi

wget "$URL" --directory-prefix=/tmp

sudo apt install "/tmp/$FILE"

wget -q -O- https://launchpad.net/ubuntu/+archivemirrors > /tmp/mirrors.txt


#This download is HTML, and is converted to URLs
grep -P -B8 "statusUP" /tmp/mirrors.txt | grep -o -P "(f|ht)tp://[^\"]*" > /tmp/filtered_mirrors.txt

echo ""
echo "   Searching... May take some time..."
sudo netselect -s10 -t20 $(cat /tmp/filtered_mirrors.txt)

echo ""
echo "Finished!"
exit 0
