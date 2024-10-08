#!/bin/bash

DEVICE=WD30EZRXB
DESTINATION=/mnt/"$DEVICE"
BACKUP_DIR="$DESTINATION"/backups-local/root

# Check if another instance of this script is running
pidof -o %PPID -x $0 >/dev/null && logger -t JOHN  "ERROR: Script $0 already running" && exit 1

now=$(date +"%Y-%m-%d-%H-%M-%S")
filenameprefix=backed-up-root
filename="$filenameprefix-$now"

logger -t JOHN  "Backing up root now: $now"

if [[ ! -f "$DESTINATION"/is.mounted ]]; then
  logger -t JOHN "$DESTINATION is NOT mounted."
else
    mkdir -p "$BACKUP_DIR"/root
    mkdir -p /var/log/backup-john
    rm -rf "$HOME"/.local/share/Trash/*
    rm -f /var/log/backup-john/"$filenameprefix"-*
    rsync -aXAHW -xx --numeric-ids --progress --exclude '.cache' /root/ "$BACKUP_DIR"/ > /var/log/backup-john/"$filename"-"$DEVICE"
fi
logger -t JOHN  "Backup of root completed: $now"
exit 0

