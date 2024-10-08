#!/bin/bash

DEVICE=WD30EZRXB
DESTINATION=/mnt/"$DEVICE"
BACKUP_DIR="$DESTINATION"/backups-local/jradley

# Check if another instance of this script is running
pidof -o %PPID -x $0 >/dev/null && logger -t JOHN "ERROR: Script $0 already running" && exit 1

now=$(date +"%Y-%m-%d-%H-%M-%S")
filenameprefix=backed-up-jradley
filename="$filenameprefix-$now"

logger -t JOHN  "Backing up jradley now: $now"

if [[ ! -f "$DESTINATION"/is.mounted ]]; then
  logger -t JOHN "$DESTINATION is NOT mounted."
else
    mkdir -p /var/log/backup-john
    mkdir -p "$DESTINATION"
    chown jradley:jradley "$DESTINATION"
    rm -rf "$HOME"/.local/share/Trash/*
    rm -f /var/log/backup-john/"$filenameprefix"-*
    rsync -aXAHW -xx --numeric-ids --progress --exclude '.cache' --exclude 'thinclient_drives' /home/jradley/ "$DESTINATION"/ > /var/log/backup-john/"$filename"-"$DEVICE"
fi
logger -t JOHN  "Backup of jradley completed: $now"
exit 0

