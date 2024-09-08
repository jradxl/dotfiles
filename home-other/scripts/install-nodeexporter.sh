#!/bin/bash

# NODE EXPORTER #

echo "Installer for a binary/systemd version of Node_Exporter for Prometheus"
echo ""
# URL "https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz"

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" |  tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

LATEST_VERSION1=$(get-github-latest https://github.com/prometheus/node_exporter)
LATEST_VERSION2="${LATEST_VERSION1/v}"
echo "Latest Version of Node_Exporter is: $LATEST_VERSION1 : $LATEST_VERSION2"

FILE_NAME1="node_exporter-$LATEST_VERSION2.linux-amd64.tar.gz"
FILE_NAME2="node_exporter-$LATEST_VERSION2.linux-amd64"

echo "Filenames are: $FILE_NAME1 : $FILE_NAME2"
echo ""

[[ -f $FILE_NAME1 ]] && rm -f $FILE_NAME1
[[ -d $FILE_NAME2 ]] && rm -rf $FILE_NAME2

if [[ $(wget "https://github.com/prometheus/node_exporter/releases/download/$LATEST_VERSION1/$FILE_NAME1") ]]; then
    echo "Download Error: Exiting"
    exit 1
fi
tar xf "$FILE_NAME1"

sudo systemctl stop node_exporter
[[ -f  /usr/local/bin/node_exporter ]] && sudo  rm -f /usr/local/bin/node_exporter
sleep 3

sudo cp "$FILE_NAME2/node_exporter"  /usr/local/bin
echo "Installed Version of Node_Exporter is: $(node_exporter --version)"

[[ -f $FILE_NAME1 ]] && rm -f $FILE_NAME1
[[ -d $FILE_NAME2 ]] && rm -rf $FILE_NAME2

sudo useradd -m --system --shell=/bin/false node_exporter
sudo groupadd --system node_exporter
sudo usermod -a -G node_exporter node_exporter

sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

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

