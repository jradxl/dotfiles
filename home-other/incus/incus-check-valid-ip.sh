#!/bin/bash

#https://www.linuxjournal.com/content/validating-ip-address-bash-script
#https://serverfault.com/questions/1120769/check-if-ip-belongs-to-a-cidr

# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
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

## Checks whether an IP address is valid within the provided CIDR Network
## Usage: is_ip_in_cidr 192.168.0.5 192.168.0.0/24
## The CIDR is checked for zero in the Host part.
function is_ip_in_cidr()
{
    local ip=$1
    local cidr=$2

    #Process the CIDR first
    local network=$(echo $cidr | cut -d/ -f1)
    local mask=$(echo $cidr | cut -d/ -f2)

    #Quad dot notation has 4 fields. Shift and add to give decimal number
    local network_dec=$(echo $network | awk -F. '{printf("%d\n", (($1 * 256 +$2) * 256 + $3) * 256 + $4) }')
    #TEST echo "network_dec: $network_dec"

    #Shift bitmask correct number of places for given mask
    local mask_dec=$((0xffffffff << (32 - $mask)))

    #TEST local mask_dec=$((0x0000000f << (32 - $mask)))
    #TEST printf "mask_dec: %x\n" $mask_dec

    #But limit bitmask to 32 bits or 8 hexidecimal places.
    local mask_dec2=$((0xffffffff & $mask_dec))
    #TEST printf "mask_dec2: %x\n" $mask_dec2

    #Check the Host part of the CIDR is Zero
    #1. Invert Mask
    local mask_dec2r=$((~$mask_dec2))
    #TEST printf "mask_dec2r: %x\n" $mask_dec2r
    #2. Limit Mask to 8 hexidecimal places
    local mask_dec2r=$((0xffffffff & $mask_dec2r))
    #TEST printf "mask_dec2r: %x\n" $mask_dec2r
    #3. Apply inverted mask to Network 
    local host_check=$(($network_dec & $mask_dec2r))
    #TEST printf "host_check: %x\n" $host_check
    if [[ $host_check != 0 ]]; then
        return 2
    fi

    #Apply mask to network address to get the bits to check
    local net1=$(($mask_dec2 & $network_dec))
    #TEST printf "net1: %x\n" $net1

    #Process the IP address. Again Quad dot notation, shift and add.
    local ip_dec=$(echo $ip | awk -F. '{printf("%d\n", (($1 * 256 +$2) * 256 + $3) * 256 + $4) }')
    #TEST echo "IP DEC: $ip_dec"

    #Apply the same mask to IP address
    local net2=$(( $mask_dec2 & $ip_dec ))
    #TEST printf "net2: %x\n" $net2

    #Now the two network components can be compared
    if [[ $net1 == $net2 ]]; then
        return 0
    else
        return 1
    fi
}

if [[ -z "$1" ]]; then
    echo "Usage: check-valid-ip.sh <ip address/mask>"
    echo "Format: 1.1.1.1/24"
    exit 1
fi

IP1=$1

if [[ $IP1 != *"/"* ]]; then
   echo "IP must end with Netmask."
   exit 1
fi

#Detach the mask ending
IP2=$(echo $IP1 | cut -d/ -f1)
echo "IP Address is: $IP2"

#Obtain the netmask
MASK=$(echo $IP1 | cut -d/ -f2)
echo "Netmask is: $MASK"

echo "Checking IP Address part: $IP2"

valid_ip $IP2
if [[ $? -eq 0 ]]; then 
    echo "Good. IP address is valid." 
else 
    echo "IP address is not valid."
    exit 1
fi

echo "Assuming Incus network bridge is incusbr0"
echo "Finding the Network and Netmask for the configuration"
INCUS_NETWORK=$(ip route | awk '/incusbr0/ {print $1}')
if [[ -z $INCUS_NETWORK ]]; then
    echo "Incus Nework on interface incusbr0 not found"
    exit 1
fi
echo "Incus Network is: $INCUS_NETWORK"
INCUS_NETWORK_IP=$(echo $INCUS_NETWORK | cut -d/ -f1)
echo "INCUS_NETWORK_IP: $INCUS_NETWORK_IP"
INCUS_NETWORK_MASK=$(echo $INCUS_NETWORK | cut -d/ -f2)
echo "INCUS_NETWORK_MASK: $INCUS_NETWORK_MASK"

if [[ $MASK != $INCUS_NETWORK_MASK ]]; then
    echo "The Netmasks do not match"
    exit 1
fi

if $(is_ip_in_cidr $IP2 $INCUS_NETWORK); then
  echo "$IP2 is in $INCUS_NETWORK"
else
  echo "$IP2 is NOT in $INCUS_NETWORK"
fi

exit 0

