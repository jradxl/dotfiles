#!/bin/bash

########################################
#
# INTENDED for nftables.conf development
#
########################################


# NOTE: modprobe br_netfilter
# NOTE: echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf

# NOTE: Prevent iptables loading /etc/apt/preferences.d/iptables.pref
# Package: iptables:any
# Pin: release *
# Pin-Priority: -1

# If not running interactively, don't do anything
interactive=""

if [[ -t 0 ]]; then
    interactive="YES"
    logger -t NFTRESTART "Restarting NFT: Interactive"
	echo "Restarting NFT: Interactive"
else
    interactive="NO"
    logger -t NFTRESTART "Restarting NFT: Non-interactive"
fi

myecho()
{
    if [[ "$interactive" == "YES" ]]; then
	    logger -t NFTRESTART "$1"
        echo "$1"
    else
        logger -t NFTRESTART "$1"
    fi
}

if [[ "$interactive" == "YES" ]]; then
    myecho "Checking syntax of nftables.conf"
    /usr/sbin/nft  -cf /etc/nftables/nftables.conf
    if [[ "$?" != "0" ]]; then
        myecho "Checking syntax failed"
        exit 0
    fi
fi

/usr/sbin/nft  -f /etc/nftables/nftables.conf
sleep 3

#/usr/bin/systemctl   restart netbird
myecho "Stoping all Incus VMs"
/usr/bin/incus stop --all
sleep 3
myecho "Shutting down Incus"
/usr/bin/incus admin shutdown -t 120
if [[ "$?" == "0" ]]; then
    myecho "Incus Daemon stopped OK."
else
    myecho "Incus daemon didn't stop. Forcing"
    /usr/bin/incus admin shutdown -t 120 -f
fi
sleep 3

#Incus service should  be enabled and this will enable socket, etc.

myecho "Restaring Incus Service and Instances using 'incus list'"
###/usr/bin/systemctl start incus
incus list -c n > /dev/null

myecho "Waiting..."
incus admin waitready

myecho "Continuing..."
if [[ "$interactive" == "YES" ]]; then
    sleep 1
    incus list
fi

myecho ""

if [[ $(command -v tailscaled) ]]; then
    myecho "Tailscaled is present."
    active=$(systemctl is-active tailscaled)
    if [[ "$active" == "active" ]]; then
        myecho "Tailscaled is active, so restarting."
        systemctl restart tailscaled
    else
        myecho "Tailscaled is not active."
    fi
else
    myecho "Tailscaled is not installed."
fi

myecho ""

if [[ $(command -v netbird) ]]; then
    myecho "Netbird is present."
    active=$(systemctl is-active netbird)
    if [[ "$active" == "active" ]]; then
        myecho "Netbird is active, so restarting."
        systemctl restart netbird
    else
        myecho "Netbird is not active."
    fi
else
    myecho "Netbird is not installed."
fi

myecho "Finished restarting NFT"
exit 0

### END ###

for i in $(incus list --columns n --format compact,noheader)
do 
    myecho "Processing $i"
    state=$(incus info $i | grep Status | awk '{ print $2 }')
    
    if [[ "$state" == "STOPPED" ]]; then
        myecho "    $i Already Stopped!"
    else
        myecho "    Stopping $i!"
        /usr/bin/incus stop "$i" --timeout 30 -q 2>/dev/null
        if [[ $? == "0" ]]; then
            myecho "    Successfully stopped $i"
        else
            myecho "    Unsuccesful stop. Using poweroff"
           /usr/bin/incus exec "$i" -- /usr/sbin/poweroff
        fi
    fi
    sleep 3

    # Only start if previously was running
    if [[ "$state" == "STOPPED" ]]; then
        myecho "    Not starting $i"
    else
        /usr/bin/incus start "$i" -q 2>/dev/null
        myecho "    Started $i"
    fi
    sleep 3
done

#/usr/bin/incus       restart --all
myecho "Finished restarting NFT"

