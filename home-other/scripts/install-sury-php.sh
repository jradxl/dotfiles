#!/bin/bash

###  https://github.com/GingerGraham/bash-logger

if  [[ $(id -u) = 0 ]]; then
   echo "This script should not be run as root."
   exit 1
fi

echo "Installing Ondre Sury PHP..."
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
LOGFILE="suryphp-install-$NOW.txt"
LOGFULLPATH="$LOGPATH/$LOGFILE"

# Initialise the logging module
init_logger --log "$LOGFULLPATH" --quiet --level INFO  2>/dev/null

source /etc/os-release
echo "See log file: $LOGFULLPATH"
log_info "SURY-PHP: $UBUNTU_CODENAME"

log_info "Getting Sury PHP keyring..."
sudo curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb

sudo tee /etc/apt/sources.list.d/sury-php-001.sources << EOF > /dev/null
Types: deb
Enabled: Yes
URIs: https://packages.sury.org/php/
Suites: ${UBUNTU_CODENAME}
Components: main
Signed-By: /etc/apt/trusted.gpg.d/debsuryorg-archive.gpg
EOF

log_info "Finshed installing SURY PHP respository"
echo "Finished. See log file"
echo ""
