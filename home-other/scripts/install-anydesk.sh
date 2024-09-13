#!/bin/bash

# Corrected Version to avoid Deprecated error
# Note that an ASCI asc file is accepted

sudo wget -qO /etc/apt/keyrings/DEB-GPG-KEY.asc https://keys.anydesk.com/repos/DEB-GPG-KEY

echo "deb [signed-by=/etc/apt/keyrings/DEB-GPG-KEY.asc] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

sudo apt update

sudo apt install anydesk

echo "DONE: Ignore any systemctl error"
exit 0

