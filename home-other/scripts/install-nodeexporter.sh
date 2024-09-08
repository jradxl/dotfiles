#!/bin/bash

# NODE EXPORTER #
# See https://github.com/prometheus/node_exporter/tree/master/examples

echo "Installer for a binary/systemd version of Node_Exporter for Prometheus"
echo ""
# URL "https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz"

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" |  tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

ARCH=$(dpkg --print-architecture)
echo "Current Architecture is: $ARCH"

LATEST_VERSION1=$(get-github-latest https://github.com/prometheus/node_exporter)
LATEST_VERSION2="${LATEST_VERSION1/v}"
echo "Latest Version of Node_Exporter is: $LATEST_VERSION1 : $LATEST_VERSION2"

FILE_NAME1="node_exporter-$LATEST_VERSION2.linux-$ARCH.tar.gz"
FILE_NAME2="node_exporter-$LATEST_VERSION2.linux-$ARCH"

echo "Filenames are: $FILE_NAME1 : $FILE_NAME2"
echo ""

#Clean any previous runs
(cd /tmp && rm -rf node_exporter* )

#Download
(wget --directory-prefix=/tmp  "https://github.com/prometheus/node_exporter/releases/download/$LATEST_VERSION1/$FILE_NAME1" )
if [[ $? -ne 0  ]]; then
    echo "Download Error: Exiting"
    exit 1
fi

#Unpack
(cd /tmp && tar xf "$FILE_NAME1")

# Stop if running so old version can be deleted.
sudo systemctl stop node_exporter
sleep 3

#Remove existing and copy in new
[[ -f  /usr/local/bin/node_exporter ]] && sudo  rm -f /usr/local/bin/node_exporter
sudo cp "/tmp/$FILE_NAME2/node_exporter"  /usr/local/bin

echo "Installed Version of Node_Exporter is: $(node_exporter --version)"

#Create Group and User
sudo groupadd --system node_exporter
sudo useradd  --system -g node_exporter  -m --shell=/sbin/nologin node_exporter

#Set up system files as per documentation
sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

#This not an Ubuntu directory
sudo mkdir -p /etc/sysconfig

sudo bash -c 'cat <<EOF > /etc/sysconfig/node_exporter
OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"
EOF'

sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.socket
[Unit]
Description=Node Exporter

[Socket]
ListenStream=9100

[Install]
WantedBy=sockets.target
EOF'

sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
Requires=node_exporter.socket

[Service]
User=node_exporter
Group=node_exporter
Type=simple
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/local/bin/node_exporter --web.systemd-socket $OPTIONS

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
sudo systemctl status --no-pager -l node_exporter

echo ""
sudo netstat -tnlp | grep node_export

echo "Finished."
exit 0

