#!/bin/bash

echo "THIS IS AN EXAMPLE: copy to root user and edit for the server's backup config."
exit 0

echo "Manually creating the first backup..."
echo "First, use ssh to ensure key fingerprint..."
mkdir -p /var/log/borgmatic/
ssh XXXXXX@XXXXX.repo.borgbase.com
echo "Starting backup..."

## Use --verbosity 2 if problems
borgmatic --verbosity 1 --log-file /var/log/borgmatic/borgmatic.log --log-file-verbosity 1
echo "Finished"
exit 0

