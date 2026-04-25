#!/bin/bash

#NEEDS https://github.com/GingerGraham/bash-logger/blob/main/logging.sh
# WGET https://raw.githubusercontent.com/GingerGraham/bash-logger/refs/heads/main/logging.sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [[ ! -f  /root/scripts/libs/logging.sh ]]; then
    echo "Missing logging.sh Library. Downloading..."
    mkdir -p /root/scripts/libs
    ( cd /root/scripts/libs && wget https://raw.githubusercontent.com/GingerGraham/bash-logger/refs/heads/main/logging.sh )    
fi

source /root/scripts/libs/logging.sh

LOGPATH="/var/log/apt-upgrade"
#MESSAGE="Upgrading apt Packages if any..."

mkdir -p "$LOGPATH"

NOW=$(date +"%Y%m%d%k%M%S")
LOGFILE="apt-upgrade_$NOW.txt"
#echo "FN: $LOGFILE"
LOGFULLPATH="$LOGPATH/$LOGFILE"

# Initialise the logging module
init_logger --log "$LOGFULLPATH" --quiet --level INFO  2>/dev/null

NUMBER=0
NUMBER=$(apt-get -q -y --ignore-hold --allow-change-held-packages --allow-unauthenticated --allow-downgrades -s dist-upgrade | /bin/grep  ^Inst | wc -l)
RET=$?
if [[ "$RET" -ne 0 ]]; then
    echo "Problem getting number of updates."
    exit 1
fi

if [[ "$NUMBER" == 0 ]]; then
	echo "There are currently no updates."
    log_info "There are currently no updates."
    exit 0
fi

log_info "Starting..."

apt-get update     >> "$LOGFULLPATH"
apt-get dist-upgrade -y >> "$LOGFULLPATH"
RET="$?"

if [[ "$RET" -ne 0  ]]; then
    log_error "Error: APT-DIST-UPGRADE had an error."
	exit 1
fi

apt-get autoremove >> "$LOGFULLPATH"

log_info "Finished"

exit 0
