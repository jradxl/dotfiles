#!/usr/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: incus-status.sh <container>"
    echo ""
    echo "Available Containers and VMs..."
    incus list
    echo ""
    exit 1
fi

echo "Checking that $1 exists..."
if [[ ! $(incus list $1 -c n -f csv) ]]; then
	echo "    Instance $1 does not exist."
	exit 1
fi

echo "Checking that $1 is stopped..."
if [[ $(incus list $1 status=stopped -c n -f csv) ]]; then
	echo "    Instance $1 is stopped."
	exit 1
fi

echo "Checking that $1 is running..."
if [[ $(incus list $1 status=running -c n -f csv) ]]; then
	echo "    Instance $1 is running."
fi

echo "Checking $1 can run a command, and wait up to 20 seconds..."
RET=$(incus exec $1 -- ls 2>/dev/null )
ERR=$?

i=0
while [[ $ERR != 0 ]]
do
    echo "    Waiting"
    sleep 2
    ((i++))
    if [[ $i -gt 20 ]]; then
    	echo "    Timed Out..."
    	exit 1
    fi
    $(incus exec $1 -- ls 2>/dev/null )
    ERR=$?
done

echo "Looking for IPv4 address..."
IPADDRESS=$(incus list $1 -c 4 -f csv | awk '{ print $1}')
echo "    Instance $1 IP Address: $IPADDRESS"

echo "Looking for the name of the interface device..."
#Remove first and last character
INTERFACE=$(incus list $1 -c 4 -f csv | awk '{ print $2}')
INTERFACE=${INTERFACE#?}
INTERFACE=${INTERFACE%?}
echo "    Instance $1 Interface Name: $INTERFACE"

echo ""
echo "Done"
exit 0


