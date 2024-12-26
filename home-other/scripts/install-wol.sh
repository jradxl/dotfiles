#!/bin/bash
sudo apt -y install wakeonlan ethtool

WOL_FILE="wol@.service"
WOL_DEFAULT="wol"

cat << EOF > /tmp/$WOL_FILE
[Unit]
Description="CUSTOM Configure Wake On LAN %I"

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s %I wol g

[Install]
WantedBy=basic.target
EOF

##Currently not used
cat << EOF > /tmp/$WOL_DEFAULT
INTERFACE=""
EOF

echo "Setting up WOL..."

if [[ -f /etc/systemd/system/$WOL_FILE ]]; then
    echo "Service $WOL_FILE already exists"
else
    echo "Installing $WOL_FILE file"
    sudo cp /tmp/$WOL_FILE /etc/systemd/system/
    sudo systemctl daemon-reload
fi

if [[ -f /etc/default/wol ]]; then
    echo "Default WOL file already exists"
else
    echo "Installing default WOL file"
    sudo cp /tmp/$WOL_DEFAULT /etc/default/
fi

for DEV in $(lspci | grep Ethernet | awk '{print $1}' )
do
  INF1=$(udevadm info -e | grep $DEV | grep "DEVPATH" | grep "net" | cut -f 2 -d\ | grep -v "lan" )  
  INF=$(basename "$INF1")
  WOL_SUPPORT=$(sudo ethtool "$INF" 2>/dev/null | grep "Supports Wake-on" )
  if [[ "$WOL_SUPPORT" == *"g"* ]]; then
    echo "Interface $INF supports Wake-on"
    sudo systemctl enable wol\@$INF.service
    sudo systemctl start wol\@$INF.service
    echo "Current Setting: $(sudo ethtool "$INF" 2>/dev/null | grep "Wake-on" | tail -1 )"
  else
    echo "Interface $INF does not support Wake-on"
  fi
  echo "MAC Address: $(cat /sys/class/net/$INF/address)"
done

echo "WOL setup finished."
exit 0

