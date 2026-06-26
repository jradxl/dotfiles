#!/bin/bash

#VERSION: 20260625-001

#1. Check not running as root

if  [[ $(id -u) = 0 ]]; then
   echo "This script should not be run as root. Exiting."
   exit 1
fi

#2. Install the Log Library
LOGLIBDIR="$HOME/scripts/libs/"

if [[ ! -f  "$LOGLIBDIR/logging.sh" ]]; then
    echo "Missing logging.sh Library. Downloading..."
    mkdir -p "$LOGLIBDIR"
    ( cd "$LOGLIBDIR" && wget https://raw.githubusercontent.com/GingerGraham/bash-logger/refs/heads/main/logging.sh )    
fi
source "$LOGLIBDIR/logging.sh"

LOGPATH="$HOME/.keepassxc/logs"
mkdir -p "$LOGPATH"

NOW=$(date +"%Y%m%d%H%M%S")
LOGFILE="keepassxc-synced-$NOW.txt"
echo "FN: $LOGFILE"
LOGFULLPATH="$LOGPATH/$LOGFILE"

# Initialise the logging module
init_logger --log "$LOGFULLPATH" --quiet --level INFO  2>/dev/null

log_info "Starting the KeepassXC sync utility"

#4. Test access to KeepassXC Sync Server
echo ""
echo "Waiting for network and KeepassXC Server availability..."
echo ""
wait4server() {
    local serverAdr="100.98.57.8"
    local count=0
    local count_max=5

    echo -e "\e[1A\e[K$(date): testing connection [$count/$count_max] - ${serverAdr}"
    ping -c 1 $serverAdr > /dev/null 2>&1
    while [[ $? -ne 0 ]]; do
      let "count+=1"
      echo -e "\e[1A\e[K$(date): testing connection [$count/$count_max] - ${serverAdr}"
      sleep 2
      if [[ ${count} -gt ${count_max} ]]; then
        echo "Server not available. Exiting"
        exit 1
      fi
      ping -c 1 $serverAdr > /dev/null 2>&1
    done

    echo "$(date): Connected - ${serverAdr}"
}
wait4server

#3. Initialize Variables
KEEPASSXC="$HOME/.keepassxc"
echo "FN: $KEEPASSXC"
KEEPASSXC_SYNCED_TMP="$KEEPASSXC/tmp"
echo "FN: $KEEPASSXC_SYNCED_TMP"
mkdir -p "$KEEPASSXC_SYNCED_TMP"
KEEPASSXC_SYNCED="$KEEPASSXC/synced"
echo "FN: $KEEPASSXC_SYNCED"

if [[ -f "$KEEPASSXC/keepassxc1.kdbx" ]]; then

    #A. Compare Size of current database with synced reference
    cmp -s "$KEEPASSXC/keepassxc1.kdbx" "$KEEPASSXC_SYNCED/keepassxc1.kdbx"

    if [[ "$?" == 0 ]]; then
        echo "Working Database is unchanged"
        echo "Proceding to check server..."
    else
        echo "Working Database has been changed."
        echo "Updating Reference copy..."
        cp "$KEEPASSXC/keepassxc1.kdbx" "$KEEPASSXC_SYNCED/keepassxc1.kdbx"
        echo "Creating new synced copy"
        cp "$KEEPASSXC/keepassxc1.kdbx" "$KEEPASSXC_SYNCED/keepassxc1-$NOW.kdbx"
        echo "Copying new file to server..."
        scp "$KEEPASSXC_SYNCED/keepassxc1-$NOW.kdbx"  jradley@keepassxc:"$KEEPASSXC_SYNCED/"
        echo "Finished Local change, and update to Server."
        exit 0
    fi
else
    echo "Currently no local active database. New install?"
    echo "Creating Dummy entries to keep going..."
    touch "$KEEPASSXC/keepassxc1.kdbx"
    touch "$KEEPASSXC_SYNCED/keepassxc1.kdbx"
fi

log_info "Checking Server"
echo "Checking Server"

#Clear tmp directory
$(cd  "$KEEPASSXC_SYNCED_TMP" && rm -f $(compgen -G "$KEEPASSXC_SYNCED_TMP/*") )

#5. Copy all keepassXC database files and find latest
scp jradley@keepassxc:"$KEEPASSXC_SYNCED/*" "$KEEPASSXC_SYNCED_TMP" >/dev/null

#6. Compare if Server's Latest is more recent than current.
#   Copy if it is
#   Replace current if it is
#   Compgen needed to expand wildcard in scripts
LATEST=$(cd "$KEEPASSXC_SYNCED_TMP"; ls -t $(compgen -G '*.kdbx') | head -n 1)
echo "LATEST IS:  $LATEST"

#Check for Reference
CURRENT=$(cd "$KEEPASSXC_SYNCED"; ls -t $(compgen -G '*.kdbx') | head -n 1)
echo "CURRENT IS: $CURRENT"

if [[ "$LATEST" == "$CURRENT" ]]; then
    echo "Current Database is latest."
else
    echo "Current Database is not latest. Copying..."
    cp "$KEEPASSXC_SYNCED_TMP/$LATEST" "$KEEPASSXC_SYNCED/"
    echo "Updating Database in use. Copying..."
    cp "$KEEPASSXC_SYNCED_TMP/$LATEST" "$KEEPASSXC/keepassxc1.kdbx"
fi

#7 Clear the temporary copies
#Clear tmp directory
$(cd  "$KEEPASSXC_SYNCED_TMP" && rm -f $(compgen -G "$KEEPASSXC_SYNCED_TMP/*") )

echo "Finished Updating from Server"
