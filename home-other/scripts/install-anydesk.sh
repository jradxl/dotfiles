#!/bin/bash

# Corrected Version to avoid Deprecated error
# Note that an ASCI asc file is accepted

#### wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
sudo wget -qO /etc/apt/keyrings/DEB-GPG-KEY.asc https://keys.anydesk.com/repos/DEB-GPG-KEY

#echo "deb http://deb.anydesk.com/ all main" >                                                   /etc/apt/sources.list.d/anydesk-stable.list
echo "deb [signed-by=/etc/apt/keyrings/DEB-GPG-KEY.asc] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

sudo apt update

sudo apt install anydesk

echo "DONE: Ignore any systemctl error"
exit 0

