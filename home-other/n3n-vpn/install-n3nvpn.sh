#!/bin/bash

echo "Installing the N3N VPN Software"

GITREPO="https://github.com/n42n/n3n.git"
REPODEST="$HOME/Devel/n3n"
ETCDIR="/etc/n3n"
STATE=""
CWD=$(pwd)
ENV=".env"
N3NUSER=n3n
EDGECONFIG="edge.conf"
SUPERCONFIG="supernode.conf"

create-envfile() {
    sudo tee "$ETCDIR/$ENV" <<-EOF > /dev/null
#EDGE CONFIG
EDGE_AUTH_PASSWORD="ChangeMe"
EDGE_AUTH_PUBKEY="Generate after install with 'n3n-edge tools keygen <supernode-fedoration>'"
EDGE_COMMUNITY_CIPHER=ChaCha20
EDGE_COMMUNITY_COMPRESSION=lzo
EDGE_COMMUNITY_HEADER_ENCRYPTION=true
EDGE_COMMUNITY_KEY="Change Me to some long random strin"
EDGE_COMMUNITY_NAME="Change me to a name of your choice"
EDGE_COMMUNITY_SUPERNODE="Change Me to domain:port, Only one supernode supported with this key"
EDGE_CONNECTION_BIND="Change me to TCP/IPv4 Address:Port"
EDGE_CONNECTION_DESCRIPTION="$HOSTNAME"
EDGE_DAEMON_USERID=$(id -u "$N3NUSER")
EDGE_DAEMON_GROUPID=$(id -g "$N3NUSER")
EDGE_TUNTAP_ADDRESS="Change Me to CDIR"
EDGE_TUNTAP_ADDRESS_MODE=static
EDGE_TUNTAP_NAME=n3n0
#EDGE CONFIG END
#SUPERNODE CONFIG
SUPER_SUPERNODE_AUTO_IP_MIN="Change Me"
SUPER_SUPERNODE_AUTO_IP_MAX="Change Me"
SUPER_COMMUNITY_FILE="/path/to/community.list"
SUPER_FEDERATION="Change Me"
SUPER_MACADDR=00:00:00:00:00:00
SUPER_PEER="Change Me to Domain:Port or comment out"
SUPER_SPOOFING_PROTECTION=true
SUPER_VERSION="Change me or comment out"
#SUPERNODE CONFIG END

EOF
}

create-configs() {
######
##  Create Edge and Supernode Config File with values known at install time
##  No subsequent processing!
######
    echo "Creating Config Files..."
    if [[ -f "$ETCDIR/$EDGECONFIG" ]]; then 
        echo "'$ETCDIR/$EDGECONFIG' already present. Not changing."
    else
        sudo tee "$ETCDIR/$EDGECONFIG" <<-EOF > /dev/null
[auth]
password="$EDGE_AUTH_PASSWORD"
pubkey="$EDGE_AUTH_PUBKEY"
[community]
cipher="$EDGE_COMMUNITY_CIPHER"
compression="$EDGE_COMMUNITY_COMPRESSION"
header_encryption="$EDGE_COMMUNITY_HEADER_ENCRYPTION"
key="$EDGE_COMMUNITY_KEY"
name="$EDGE_COMMUNITY_NAME"
supernode="$EDGE_COMMUNITY_SUPERNODE"
supernode1="Change Me or comment out"
supernode2="Change Me or comment out"
supernodeN="Change Me or comment out"
[connection]
advertise_addr=auto
allow_p2p=true
bind="$EDGE_CONNECTION_BIND"
connect_tcp=false
description="$EDGE_CONNECTION_DESCRIPTION"
pmtu_discovery=false
register_interval=20
register_pkt_ttl=0
supernode_selection=load
tos=0
[daemon]
userid="$EDGE_DAEMON_USERID"
groupid="$EDGE_DAEMON_GROUPID"
background=false
[filter]
allow_multicast=false
allow_routing=false
#rule=
[logging]
verbose=2
[management]
enable_debug_pages=false
password=n3n
port=0
unix_sock_perms=0
[tuntap]
address="$EDGE_TUNTAP_ADDRESS"
address_mode="$EDGE_TUNTAP_ADDRESS_MODE"
#macaddr=
metric=0
mtu=1290
name="$EDGE_TUNTAP_NAME"

EOF
    echo "'$ETCDIR/$EDGECONFIG' created."
    fi

    if [[ -f "$ETCDIR/$SUPERCONFIG" ]]; then 
        echo "'$ETCDIR/$SUPERCONFIG' already present. Not changing."
    else
        sudo tee "$ETCDIR/$SUPERCONFIG" <<-EOF > /dev/null
[auth]
password="$EDGE_AUTH_PASSWORD"
pubkey="$EDGE_AUTH_PUBKEY"
[community]
cipher="$EDGE_COMMUNITY_CIPHER"
compression="$EDGE_COMMUNITY_COMPRESSION"
header_encryption="$EDGE_COMMUNITY_HEADER_ENCRYPTION"
key="$EDGE_COMMUNITY_KEY"
name="$EDGE_COMMUNITY_NAME"
#supernode="Comment out on Supernode"
[connection]
advertise_addr=auto
allow_p2p=true
#bind="Comment out on Supernode"
connect_tcp=false
description="$EDGE_CONNECTION_DESCRIPTION"
pmtu_discovery=false
register_interval=20
register_pkt_ttl=0
supernode_selection=load
tos=0
[daemon]
userid="$EDGE_DAEMON_USERID"
groupid="$EDGE_DAEMON_GROUPID"
background=false
[filter]
allow_multicast=false
allow_routing=false
rule="Change Me or comment out"
[logging]
verbose=2
[management]
enable_debug_pages=false
password=n3n
port=0
unix_sock_perms=0
#[tuntap]
#address="$EDGE_TUNTAP_ADDRESS"
#address_mode="$EDGE_TUNTAP_ADDRESS_MODE"
#macaddr=
#metric=0
#mtu=1290
#name="$EDGE_TUNTAP_NAME"
[supernode]
auto_ip_min="Change Me CIDR"
auto_ip_max="Change Me CDIR"
community_file="$ETCDIR"/community.list
federation="Change Me"
macaddr=00:00:00:00:00:00
spoofing_protection=true
version="Change Me or comment out"

EOF
    echo "'$ETCDIR/$SUPERCONFIG' created."
    fi
    
    echo "Done.. You will need to edit the config files per requirements before runing executables."
}

check-for-env() {
   if [[ -d "$ETCDIR" ]]; then
       if [[ ! -f "$ETCDIR/$ENV" ]]; then
           echo "No environment file, '$ENV' : Creating... "
           create-envfile
           #exit 1
       fi
   else
       echo "No '"$ETCDIR"' directory and no environment file, '$ENV' : Creating... "
       sudo mkdir -p "$ETCDIR"
       create-envfile
       #exit 1
   fi
   echo "Done..."
   source "$ETCDIR/.env"
}

install-n3n() {
    sudo useradd -r -M -s /usr/sbin/nologin n3n
    ##Remove a failed build
    sudo rm -rf "$REPODEST"
    mkdir -p "$REPODEST"
    cd "$REPODEST"
    git clone "$GITREPO"
    cd n3n
    git submodule update --init --recursive
    "$REPODEST"/n3n/autogen.sh
    #Build Options: CFLAGS="-O3 -march=native" --with-openssl --enable-pthread --enable-cap --enable-pcap --enable-natpmp --enable-miniupnp
    "$REPODEST"/n3n/configure CFLAGS="-O3 -march=native" --with-zstd --with-openssl --enable-pthread --enable-cap --enable-pcap --enable-natpmp --enable-miniupnp
    if [[ $? != 0 ]]; then
        echo "Configure Error: Exiting..."
        exit 1
    fi
    make
    sudo make install

    if [[ ! $(grep  local /usr/local/lib/systemd/system/n3n-edge.service) ]]; then
        sudo sed -i 's!sbin!local/sbin!g' /usr/local/lib/systemd/system/n3n-edge.service
    fi
    if [[ ! $(grep  local /usr/local/lib/systemd/system/n3n-supernode.service) ]]; then
        sudo sed -i 's!sbin!local/sbin!g' /usr/local/lib/systemd/system/n3n-supernode.service
    fi

    sudo cp /usr/local/lib/systemd/system/n3n-edge.service /etc/systemd/system
    sudo cp /usr/local/lib/systemd/system/n3n-supernode.service /etc/systemd/system
    
    sudo systemctl daemon-reload
}

upgrade-n3n() {
    cd "$REPODEST"
    make clean
    install-n3n
}

#Used when testing this script
uninstall-n3n() {
    echo "Uninstalling as requested..."
    WHERE=$(which n3n-edge)
    if [[  "$WHERE" == *"local"* ]]; then
        LOCAL="local"
    else
        LOCAL=""
    fi
    sudo rm -f /usr/"$LOCAL"/sbin/n3n-supernode 
    sudo rm -f /usr/"$LOCAL"/sbin/n3n-edge
    sudo rm -f /usr/"$LOCAL"/bin/n3nctl 

    sudo rm -f /usr/"$LOCAL"/lib/systemd/system/n3n-edge@.service
    sudo rm -f /usr/"$LOCAL"/lib/systemd/system/n3n-edge.service
    sudo rm -f /usr/"$LOCAL"/lib/systemd/system/n3n-supernode.service

    sudo rm -f /usr/"$LOCAL"/share/man/man8/n3n-edge.8.gz
    sudo rm -f /usr/"$LOCAL"/share/man/man8/n3n-supernode.8.gz
    sudo rm -f /usr/"$LOCAL"/share/man/man7/n3n.7.gz 
    
    sudo rm -rf /usr/"$LOCAL"/share/doc/n3n/
    sudo rm -rf "$REPODEST"
    echo "Uninstall completed"
}

## MAIN ##

### TESTING
# uninstall-n3n
###

if [[ $(command -v n3n-edge) ]]; then
    echo "N3N already installed"
    STATE="ALREADY"
else
    echo "N3N not installed. Installing..."
    STATE="INSTALL"
    echo "Installing dependancies..."
    sudo apt-get -q -y update &&
    sudo apt-get -q -y upgrade &&
    sudo apt-get install -y -q wget build-essential git autoconf libzstd-dev liblzo2-dev libssl-dev libnatpmp-dev libminiupnpc-dev libpcap-dev libcap-dev
    if [[ $(command -v lastversion) ]]; then
        echo "Found lastversion. Continuing..."
    else
        echo "Please install PIPX and LASTVERSION"
        exit 1
    fi
    install-n3n
    check-for-env
    create-configs   
    echo "Install completed"
fi

URL=${GITREPO%.*}
LATEST=v$(lastversion "$URL")
echo "Latest Version: $LATEST"

CURRENT=$(n3n-edge -V | grep n3n | awk '{print $2}')
ARR=(${CURRENT//-/ })
CURRENT=${ARR[0]}
echo "Current Version $CURRENT"

if [[ "$CURRENT" == "$LATEST" ]]; then
    echo "N3N is already the latest version"
else
    echo "Upgrading N3N..."
    upgrade-n3n
    echo "Upgrade completed"
fi

