#!/bin/bash

INSTANCE="u3"
DESIRED_STATIC_IP="10.155.89.213/24"
##Host
NETWORK_NAME=$(incus profile device get default eth0 network)
echo "Default Profile HOST Network Name: $NETWORK_NAME"

NETWORK_ADDRESS=$(route -n | grep $NETWORK_NAME | awk '{split($0, a, " "); print a[1]}')
echo "Network address: $NETWORK_ADDRESS"

SUBNET_MASK=$(ifconfig incusbr0 | awk '/netmask/{print $4;}')
echo "Subnet Mask: $SUBNET_MASK"

NETWORK=$(ip route | awk '/incusbr0/ {print $1}')
echo "Full Network: $NETWORK"

DHCP_RANGE=$(incus network get $NETWORK_NAME ipv4.dhcp.ranges)
echo "Network DHCP Range: $DHCP_RANGE"


##Instance
INSTANCE_IFNAME=$(incus exec "$INSTANCE" -- ip route | awk '/default/ { print $5 }')
echo "Instance Interface Name: $INSTANCE_IFNAME"

INSTANCE_GATEWAY=$(incus exec "$INSTANCE" -- ip route | awk '/default/ { print $3 }')
echo "Instance Gateway IP: $INSTANCE_GATEWAY"

INSTANCE_CURRENT_IP1=$(incus exec "$INSTANCE" -- ip addr show "$INSTANCE_IFNAME" | grep "inet" | head -n 1 | awk '/inet/ {print $2}')
echo "Instance Current IP1: $INSTANCE_CURRENT_IP1"

INSTANCE_CURRENT_IP2=$( echo $INSTANCE_CURRENT_IP1 | cut -d'/' -f1 )
echo "Instance Current IP2: $INSTANCE_CURRENT_IP2"


NETPLAN_LIST=$(incus exec "$INSTANCE" -- ls /etc/netplan)
#echo "Files found in /etc/netplan: $NETPLAN_LIST"


OLD_IFS=$IFS
IFS=$'\n'

#Incus Delete only actions one file
for i in $(incus exec "$INSTANCE" -- ls /etc/netplan); do
	echo "Deleting $i: $(incus file delete "$INSTANCE"/etc/netplan/$i)"
done

IFS=$OLD_IFS

##incus file delete u1/etc/netplan/20-lxc.yaml

printf "%s\n" \
"network:" \
"  version: 2" \
"  ethernets:" \
"    $INSTANCE_IFNAME:" \
"      dhcp4: false" \
"      addresses:" \
"        - $DESIRED_STATIC_IP" \
"      routes:" \
"        - to: default" \
"          via: $INSTANCE_GATEWAY" \
"      nameservers:" \
"        addresses: [8.8.8.8, 8.8.4.4]" \
> /tmp/10-lxc.yaml

chmod 600 /tmp/10-lxc.yaml

incus file push /tmp/10-lxc.yaml $INSTANCE/etc/netplan/10-lxc.yaml

incus exec $INSTANCE -- chown root:root /etc/netplan/10-lxc.yaml

incus exec "$INSTANCE" -- netplan apply

