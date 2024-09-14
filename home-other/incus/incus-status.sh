#!/usr/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: incus-status.sh <container>"
    exit 1
fi

if [[ ! $(incus list $1 -c n -f csv) ]]; then
	echo "Instance $1 does not exist."
	exit 1
fi

if [[ $(incus list $1 status=stopped -c n -f csv) ]]; then
	echo "Instance $1 is stopped."
	exit 1
fi

if [[ $(incus list $1 status=running -c n -f csv) ]]; then
	echo "Instance $1 is running."
fi

i=0
$(incus exec u3 -- ls)
RET=$?
while [[ $RET != 0 ]]
do
    echo "Waiting"
    sleep 2
    ((i++))
    if [[ $i -gt 20 ]]; then
    	echo "Timed Out..."
    	exit 1
    fi
    $(incus exec u3 -- ls)
    RET=$?
done

IPADDRESS=$(incus list $1 -c 4 -f csv | awk '{ print $1}')
echo "Instance $1 IP Address: $IPADDRESS"

#Remove first and last character
INTERFACE=$(incus list $1 -c 4 -f csv | awk '{ print $2}')
INTERFACE=${INTERFACE#?}
INTERFACE=${INTERFACE%?}
echo "Instance $1 Interface Name: $INTERFACE"

