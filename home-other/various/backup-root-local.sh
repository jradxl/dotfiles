#!/bin/bash

DESTINATION=/mnt/disk1

# Check if another instance of this script is running
pidof -o %PPID -x $0 >/dev/null && logger -t JOHN  "ERROR: Script $0 already running" && exit 1

now=$(date +"%Y-%m-%d-%H-%M-%S")
filename="backed-up-root-$now"

logger -t JOHN  "Backing up root now: $now"

if [[ ! -f "$DESTINATION"/is.mounted ]]; then
  logger -t JOHN "$DESTINATION is NOT mounted."
else
    mkdir -p "$DESTINATION"/home/root
    mkdir -p /var/log/backup-john
    rm -rf "$HOME"/.local/share/Trash/*
    rm -f /var/log/backup-john/backed-up-root-*
    rsync -aXAHW -xx --numeric-ids --progress --exclude '.cache' /root/ "$DESTINATION"/home/root/ > /var/log/backup-john/"$filename"-disk1
fi
logger -t JOHN  "Backup of root completed: $now"
exit 0

