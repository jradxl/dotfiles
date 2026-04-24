#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -f  /root/scripts/libs/logging.sh ]]; then
    source /root/scripts/libs/logging.sh
else
    echo "Missing loggimg.sh Library"
    exit 0
fi

LOGPATH="/var/log/apt-upgrade"
MESSAGE="Upgrading apt Packages if any..."

mkdir -p "$LOGPATH"

NOW=$(date +"%Y%m%d%k%M%S")
LOGFILE="apt-upgrade_$NOW.txt"
LOGFULLPATH="$LOGPATH/$LOGFILE"

# Initialise the logging module
init_logger --log $LOGFULLPATH --quiet --level INFO  2>/dev/null

NUMBER=$(apt-get -q -y --ignore-hold --allow-change-held-packages --allow-unauthenticated -s dist-upgrade | /bin/grep  ^Inst | wc -l)
if [[ "$NUMBER" == 0 ]]; then
	echo "There are currently no updates."
    log_info "There are currently no updates."
    exit 0
fi


log_info "Starting..."

apt-get update     >> $LOGFULLPATH
apt-get dist-upgrade -y >> $LOGFULLPATH
RET="$?"

if [[ "$RET" -ne 0  ]]; then
    log_error "Error: APT-DIST-UPGRADE had an error."
	exit 1
fi

apt-get autoremove

log_info "Finished"

exit 0

