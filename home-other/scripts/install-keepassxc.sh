#!/bin/bash

if  [[ $(id -u) = 0 ]]; then
   echo "This script should not be run as root."
   exit 1
fi

echo "Installing KeePassXC..."
echo "Script will ask for Sudo Password."
echo ""


#2. Install the Log Library
LOGLIBDIR="$HOME/scripts/libs/"

if [[ ! -f  "$LOGLIBDIR/logging.sh" ]]; then
    echo "Missing logging.sh Library. Downloading..."
    mkdir -p "$LOGLIBDIR"
    ( cd "$LOGLIBDIR" && wget https://raw.githubusercontent.com/GingerGraham/bash-logger/refs/heads/main/logging.sh )    
fi
source "$LOGLIBDIR/logging.sh"

LOGPATH="$HOME/logs"
mkdir -p "$LOGPATH"

NOW=$(date +"%Y%m%d%H%M%S")
LOGFILE="keepassxc-install-$NOW.txt"
#echo "FN: $LOGFILE"
LOGFULLPATH="$LOGPATH/$LOGFILE"

# Initialise the logging module
init_logger --log "$LOGFULLPATH" --quiet --level INFO  2>/dev/null

source /etc/os-release
#echo "FN: $UBUNTU_CODENAME"

log_info "Starting the KeepassXC Install utility"

mkdir -p   "$HOME/.ssh"
chmod 700  "$HOME/.ssh"
touch      "$HOME/.ssh/config"
chmod 600  "$HOME/.ssh/config"

#Grep for Exact String
grep -q ^"Host keepassxc"$ "$HOME/.ssh/config"
if [[ "$?" != 0  ]]; then
#tee, set to append, if not present
tee -a $HOME/.ssh/config << EOF > /dev/null
Host keepassxc
     User ${USER}
     HostName 100.98.57.8
     PreferredAuthentications publickey
     #AddKeysToAgent yes
     IdentityFile ~/.ssh/my-keys/keepassxc.key
EOF
fi

sudo tee /etc/apt/sources.list.d/keepassxc.sources << EOF > /dev/null
Types: deb
URIs: https://ppa.launchpadcontent.net/phoerious/keepassxc/ubuntu/
Suites: ${UBUNTU_CODENAME}
Components: main
Signed-By:
 -----BEGIN PGP PUBLIC KEY BLOCK-----
 .
 mQINBFnudIUBEAC/OhysfBjueQn2sIIHjkMJGDBZlRj/IcnVRD0G2eE5LvlQkohi
 c5qwRDZW3JhjnOsnJTsZ10uU/KO178X92J+x8poQU8mgUsjSqCvKrj5nVSsg9olL
 AC5IiTrhkR8klaL80F3VWsyhzLAPh7gwp14OOWw22y3qcuVnXdIW2ZCCt2bJFW4b
 Y2/3n37uSibcGIAVHDEpF/vSKcHtS9ggAhsYC8RJK0h61BS0mcxAo9tl3zyv+cHG
 zA64GfqRl3GE2RL4pOOROb7aIOC+2z/DiF/XFTuB2xFVNx1yvKSPiGlq5QScVWmu
 depBH20mFgRVXXyWq+Ldm7Y8MNL9sIhdLm+mOI9P/k5NEuhfiE9KZ2Op/Knf0KXq
 ywmaJGjkt3WCZ11UiuXG98m3RGL+/g4YZZ9JyfVHHQyOWZNIBtMWedX57fTDK6QP
 U76YX4LUMidaXZRj1ZTmI1oPcIm8U/jH99xKoctdb6bAj5GvdC8CJFvaI/UMAKQ+
 5M9MRtfvv0iukBKz3y7CtaXdipR0mWSiAe8PTJpaOP8q3Q/fGj9MW/w2hH6ZPHZq
 cqM6uWIQzO/gT49xn4ke59DXCyJ2jLBaJAeuZx6KF9MGO7zCPlZVF0zHILoCOQMi
 Y8ddhuy6MuJTeZIavHaSdv0cDbm1/ccJ50vNGAaAUh1YyXtTsLLbxYS8ywARAQAB
 tCJMYXVuY2hwYWQgUFBBIGZvciBKYW5layBCZXZlbmRvcmZmiQI4BBMBAgAiBQJZ
 7nSFAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBhkiq2AGj81sw0EAC2
 KTilCHZLVsj8Ap6iuBcZ+p5JDeFRBnR6h6C2pNFIqEkYZFiKQ04OAcZqS5F/cLOM
 GIPysoXI+MkIqwGIKaix0B7ykway9DaiZ40q5lzFpnspruaqO0caZHWmMGX4c2db
 Y+SazOsUzdUWfRM30qO0enGPqfuuDTmvk3Y89XB0niBh380AGwzsGM4/PBcMpNdH
 clrIVy9Hi3etFVG8TYdAKuXSozp7GBjwL5QBtC2axTUooUZRpI+yaPFUCn3UIe8j
 WlL19eRqvAeE8wrgn9WstY6m0D8u6pNIYw/yr8Hk6AQXeHYpuNjR2bDWcJe4wH8A
 mufqUYs/oArHqRLYtleawR4wqZJWDjUXZ7/2/fSNzM7VI3jSSpeg7UkLitl8ajS3
 6d4Bm1WrFp9AqAuTXetTryQotmfYaZP7xmKI4El4cagJARxRApdHdxYOjWXLdmi3
 XX/YNXqu+QtBUMT20mSk3TLu9XoOJG78eHdWgUB8NEW9fRtVETKSzYIGzZWNU8f0
 xksMDKhNR93EXY4aoN6eZoWme359gkY9H6R7xYMHwe39m0LK3J8CgisqMX+zsHQ0
 5uCjvg7GTuOgYhMBwIRPowqR6FOIY6pkaEFb2FF8yL1Ke+36WeMlLjLS7Up3Z4H1
 HoNSCNFztmWQTuJgTH/uxxL2D35UdOhsQLFf4Uu/bg==
 =WgOm
 -----END PGP PUBLIC KEY BLOCK-----
EOF

case $UBUNTU_CODENAME in

  noble)
    echo "Noble Detected... Installing keepassxc"
    sudo apt-get -y update && sudo apt-get -y install keepassxc
    ;;

  resolute)
    echo "Resolute detected... Installing keepassxc-full"
    sudo apt-get -y update && sudo apt-get -y install keepassxc-full
    ;;
  *)
    echo "ERROR: Unknown"
    ;;
esac

echo ""
mkdir -p "$HOME/.ssh/my-keys"
touch "$HOME/.ssh/my-keys/keepassxc.key"
chmod 600 "$HOME/.ssh/my-keys/keepassxc.key"
echo "Now add the private key for your KeepassXC Sync Server..."
echo ""
