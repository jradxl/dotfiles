#!/bin/bash

DESTINATION=/mnt/disk1

# Check if another instance of this script is running
pidof -o %PPID -x $0 >/dev/null && logger -t JOHN "ERROR: Script $0 already running" && exit 1

now=$(date +"%Y-%m-%d-%H-%M-%S")
filename="backed-up-jradley-$now"

logger -t JOHN  "Backing up jradley now: $now"

if [[ ! -f "$DESTINATION"/is.mounted ]]; then
  logger -t JOHN "$DESTINATION is NOT mounted."
else
    mkdir -p /var/log/backup-john
    mkdir -p "$DESTINATION"/home/jradley
    chown jradley:jradley "$DESTINATION"/home/jradley
    rm -rf "$HOME"/.local/share/Trash/*
    rm -f /var/log/backup-john/backed-up-jradley-*
    rsync -aXAHW -xx --numeric-ids --progress --exclude '.cache' /home/jradley/ "$DESTINATION"/home/jradley/ > /var/log/backup-john/"$filename"-disk1
fi
logger -t JOHN  "Backup of jradley completed: $now"
exit 0

