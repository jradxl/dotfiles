#!/bin/bash

# basic cache delete script
# 14. 05. 2020, Bence Vági, vagi.bence@gmail.com
# 2024/10/01, John Radley jradxl@gmail.com
# Non-interactive version 
# Deletes the dependencies cache and nothing else.

preproc=""
slash="/"

preproc="$(deno info | grep 'Remote modules cache:')"

echo "Deno Info Remote Cache Location: $preproc"

if [[ -z "$preproc" ]]; then 
        echo "directory not found, exiting"; 
        exit 0;
fi


##denodir="$(echo $preproc | awk -F "\"" '{print $2}' | awk '{print $1"/https"}')"
denodir="$(echo $preproc | awk '/Remote modules cache:/ {print $4}' )"

echo "Deleting contents at this path: $denodir$slash"

rm -rf $denodir$slash

echo "Exiting script"

exit 0
