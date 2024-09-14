#!/bin/bash

#https://serverfault.com/questions/1120769/check-if-ip-belongs-to-a-cidr

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
    #TEST printf "mask_dec: %x\n", $mask_dec

    #But limit bitmask to 32 bits or 8 hexidecimal places.
    local mask_dec2=$((0xffffffff & $mask_dec))
    #TEST printf "mask_dec2: %x\n", $mask_dec2

    #Apply mask to network address to get the bits to check
    local net1=$(( $mask_dec2 & $network_dec ))
    #TEST printf "net1: %x\n", $net1

    #Process the IP address. Again Quad dot notation, shift and add.
    local ip_dec=$(echo $ip | awk -F. '{printf("%d\n", (($1 * 256 +$2) * 256 + $3) * 256 + $4) }')
    #TEST echo "IP DEC: $ip_dec"

    #Apply the same mask to IP address
    local net2=$(( $mask_dec2 & $ip_dec ))
    #TEST printf "net2: %x\n", $net2

    #Now the two network components can be compared
    if [[ $net1 == $net2 ]]; then
        return 0
    else
        return 1
    fi
}

# Test the function with a sample IP address and CIDR
ip="192.168.1.5"
cidr="192.168.1.0/24"

if $(is_ip_in_cidr $ip $cidr); then
    echo "YES, $ip is IN $cidr"
else
    echo "NO, $ip is NOT in $cidr"
fi

echo ""

ip="192.168.1.5"
cidr="192.168.0.0/24"

if $(is_ip_in_cidr $ip $cidr); then
    echo "YES, $ip is IN $cidr"
else
    echo "NO, $ip is NOT in $cidr"
fi

