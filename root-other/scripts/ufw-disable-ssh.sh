#!/bin/bash

echo "Restarting and disabling OpenSSH by UFW..."

systemctl restart ufw
systemctl enable ufw
ufw delete allow OpenSSH
ufw reload
ufw enable
ufw status
tailscale ip -4
