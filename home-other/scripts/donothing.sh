#!/bin/bash
date=$(date +"%Y-%m-%d-%H%M%S")
echo "It worked at $date..." > "/tmp/testfile_$date.txt"
exit 0

