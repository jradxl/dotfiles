#!/bin/bash

INSTANCE=""
DESIRED_STATIC_IP="10.155.89.215/24"
NETPLAN_FILE="10-netplan.yaml"

echo "Sets a Static IP to an Instance connected to the incusbr0 interface."
echo "Use this script with care..."
echo ""

############ Function ###########
#Returns 0 if valid, 1 if not
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}
############ Function End ###########

############ MAIN ###########

if [[ -z "$1" ]]; then
    echo "Usage: incus-set-static-address.sh <container>"
    exit 1
fi

echo "Checking Instance..."
INSTANCE=$1

if [[ ! $(incus list $INSTANCE -c n -f csv) ]]; then
	echo "Instance $INSTANCE does not exist."
	exit 1
fi

if [[ $(incus list $INSTANCE status=stopped -c n -f csv) ]]; then
	echo "Instance $INSTANCE is stopped."
	exit 1
fi

if [[ $(incus list $INSTANCE status=running -c n -f csv) ]]; then
	echo "Instance $INSTANCE is running."
fi

echo "Waitng for a Virtal Machine instance to come online if recently started."
echo ""

i=0
$(incus exec $INSTANCE -- ls)
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
    $(incus exec $INSTANCE -- ls)
    RET=$?
done

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
echo "Instance Current with Mask: $INSTANCE_CURRENT_IP1"

INSTANCE_CURRENT_IP2=$( echo $INSTANCE_CURRENT_IP1 | cut -d'/' -f1 )
echo "Instance Current without Mask: $INSTANCE_CURRENT_IP2"

echo "Requested IP address with Mask: $DESIRED_STATIC_IP"

NETPLAN_LIST=$(incus exec "$INSTANCE" -- ls /etc/netplan)
#echo "Files found in /etc/netplan: $NETPLAN_LIST"

##Obtain User's choice of IP address.

echo "Using the information presented about, make your choice of Static IP address."
echo "Notice the configurated DHCP IP range shown above. There is no check your choice"
echo " does not overlap the range."

LOOP=1
VALID=0

while ((LOOP <= 5)) ; do
    echo "Write your desired IP address, including netmask in CIDR notation:"
    read -r line
    IP=$(echo $line | cut -d/ -f1)
    MASK=$(echo $line | awk -F/ '{ print $2}')
    if [[ -z $MASK ]]; then
        echo "The netmask must be provided."
    else
        ((VALID++))
    fi
    valid_ip $IP
    if [[ $? == 0 ]]; then
        ((VALID++))
    fi
    if [[ $VALID == 2 ]]; then
        break
    fi
    echo "IP incorrect. Try again or Cntrl-C to quit"
    ((LOOP++))
    VALID=0
done
echo $loop
if [[ $loop > 5 ]]; then
    echo "Script gave up after 5 retries."
    exit 1
fi

DESIRED_STATIC_IP=$IP/$MASK
echo "IP address is OK."
echo "Continuing with: $DESIRED_STATIC_IP"

#OLD_IFS=$IFS
#IFS=$'\n'

#Incus Delete only actions one file
for i in $(incus exec "$INSTANCE" -- ls /etc/netplan); do
	echo "Deleting existing Netplan config file $i: $(incus file delete "$INSTANCE"/etc/netplan/$i)"
done

IFS=$OLD_IFS

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
> /tmp/$NETPLAN_FILE

chmod 600 /tmp/$NETPLAN_FILE

echo "Pushing new config file to instance."
incus file push /tmp/$NETPLAN_FILE $INSTANCE/etc/netplan/$NETPLAN_FILE

incus exec $INSTANCE -- chown root:root /etc/netplan/$NETPLAN_FILE

echo "Apply new configuration."
incus exec "$INSTANCE" -- netplan apply

echo ""
echo "New Static IP applied to $INSTANCE"
incus list $INSTANCE
echo "Waiting 5 seconds to ensure IP change."
sleep 5
incus list $INSTANCE
echo "Done."

