#!/bin/bash

BASEFILE="xrdp-installer-1.5.2"
URL="https://c-nergy.be/downloads/xRDP/$BASEFILE.zip"
INSTALL=""

echo "Building and installing XRDP and XORGXRDB from sources from c-nergy.be ..."
if [[ $(dpkg -l xrdp) ]]; then
    echo "XRDP already installing"
    INSTALL="NO"
else
    INSTALL="YES"
fi

if [[ $(dpkg -l xorgxrdp ) ]]; then
    echo "XORGXRDP already installing"
    INSTALL="NO"
else
    if [[ "$INSTALL" == "NO" ]]; then
        echo "XRDP is installed without XORGXRDP"
	echo "Not supported. Exiting"
	exit 1
    else
        INSTALL="YES"
    fi
fi

if [[ "$INSTALL" == "NO" ]]; then
   echo "Doing nothing..."
else
   echo "Installing xrdp and Xorgxrdp..."   
   rm -f "/tmp/$BASEFILE"*
   (cd /tmp && wget "$URL")
   ls -al /tmp
   if [[ -f "/tmp/$BASEFILE.zip" ]]; then
       unzip -d /tmp "/tmp/$BASEFILE.zip"
       RES="$?"
       if [[ "$RES" != "0" ]]; then
           echo "$FILE.zip did not unzip correctly. Exiting."
           exit 1
       fi
       echo ""
       echo "RUNNING the install script..."
       echo ""
       /tmp/$BASEFILE.sh -c
       echo ""
       echo "COMPLETED. Best to reboot!"
   else
       echo "$BASEFILE.zip did not download correctly. Exiting."
       exit 1
   fi
fi
echo "Done."
exit 0

