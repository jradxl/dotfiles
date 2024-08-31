#!/bin/bash

##Must be in /usr/local/bin

date=$(date +"%Y-%m-%d-%H%M%S")
echo "Setting up Bridges at $date..." > "/tmp/setup-bridges_$date.txt"

for i in $(seq 0 1); do
    echo "Deleteing Interface br1tap$i"
    { ip link set dev br1tap$i down 1> /dev/null 2> /dev/null;  }
    { ip link del dev br1tap$i 1> /dev/null 2> /dev/null; }
done

for i in $(seq 0 1); do
    echo "Deleteing Interface br2tap$i"
    { ip link set dev br2tap$i down 1> /dev/null 2> /dev/null;  }
    { ip link del dev br2tap$i 1> /dev/null 2> /dev/null; }
done

{ ip addr show br1 1> /dev/null 2> /dev/null ; }
if [[ $? == 0 ]]; then
  echo "br1 exists"
  { ip link set dev br1 down; }
  { ip link del dev br1; }
else
  echo "br1 not exists"
fi

{ ip addr show br2 1> /dev/null 2> /dev/null ; }
if [[ $? == 0 ]]; then
  echo "br2 exists"
  { ip link set dev br2 down; }
  { ip link del dev br2; }
else
  echo "br2 not exists"
fi


ip link add name br1 type bridge;
brctl addbr br2
 
for i in 0 1; do

    echo "Creating $i"
    ip tuntap add dev br1tap$i mode tap
    ip link set dev br1tap$i up
    ip link set dev br1tap$i master br1
    
    ip tuntap add dev br2tap$i mode tap
    ip link set dev br2tap$i up
    ip link set dev br2tap$i master br2
done;

ip link set up dev br2
ip link set up dev br1

exit 0

#ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]

#Usage: ip tuntap { add | del | show | list | lst | help } [ dev PHYS_DEV ]
#       [ mode { tun | tap } ] [ user USER ] [ group GROUP ]
#       [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ] [ name NAME ]

