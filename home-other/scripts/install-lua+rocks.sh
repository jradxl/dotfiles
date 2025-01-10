#!/bin/bash

echo "Installing LUA and LUAROCKS...."
echo "Removing all LUA* packages if installed"
sudo apt-get purge -y lua* >/dev/null
sudo apt-get purge -y luarocks* >/dev/null
sudo apt-get -y autoremove >/dev/null

INSTALL="NO"
LATESTVERSION=""
if [[ $(command -v lastversion) ]]; then
    LATESTVERSION=$(lastversion https://github.com/lua/lua)
else
    echo "Please install Lastversion first."
    exit 1
fi

echo "Latest version: <$LATESTVERSION>"
BASEFILE="lua-$LATESTVERSION"
FILE="$BASEFILE.tar.gz"
URL="https://www.lua.org/ftp/$FILE"

CURRENTVERSION=""
if [[ $(command -v lua) ]]; then
    CURRENTVERSION=$(lua -v | awk '{print $2}')
else
    INSTALL="YES"
fi
echo "Current version: <$CURRENTVERSION>"

if [[ "$CURRENTVERSION" != "$LATESTVERSION" ]]; then
INSTALL="YES" 
fi

if [[  "$INSTALL" == "YES" ]]; then
   echo "Starting LUA build from source..."
    
   rm -rf "/tmp/$BASEFILE"*
   (cd /tmp && wget "$URL")
   (cd /tmp && tar xf "$FILE")
   (cd /tmp/$BASEFILE && make all test)
   #ls -al /tmp/$BASEFILE/src/lua*
   (cd /tmp/$BASEFILE && sudo make install )
else
    echo "Current version of LUA is already installed."
fi
hash -r
echo "Installed versions of LUA and LUAC are:"
lua -v
luac -v

echo ""
echo "Checking for LUAROCKS..."
CURRENTVERSION=$(luarocks --version | grep luarocks | awk '{print $2}')
echo "Current version of Luarocks: <$CURRENTVERSION>"

LATESTVERSION=$(lastversion https://github.com/luarocks/luarocks)
echo "Latest version of Luarocks: <$LATESTVERSION>"

BASEFILE="luarocks-$LATESTVERSION"
FILE="$BASEFILE.tar.gz"
URL="https://luarocks.org/releases/$FILE"

if [[ "$CURRENTVERSION" != "$LATESTVERSION" ]]; then
   echo "Starting LUAROCKS build from source..."
    
   rm -rf "/tmp/$BASEFILE"*
   (cd /tmp && wget "$URL")
   (cd /tmp && tar xf "$FILE")
   (cd /tmp/$BASEFILE && ./configure)
   (cd /tmp/$BASEFILE && make)
   (cd /tmp/$BASEFILE && sudo make install)
   #ls -al /tmp/$BASEFILE/
else
    echo "Latest version of Luarocks is already installed."
fi

#$ wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz
#$ tar zxpf luarocks-3.11.1.tar.gz
#$ cd luarocks-3.11.1
#$ ./configure && make && sudo make install
echo ""
hash -r
echo "Installed versions of LUAROCKS and LUAROCKS-ADMIN are:"
luarocks --version
luarocks-admin --version
echo "Done."

