#!/bin/bash

echo "Restarting and enabling UFW..."

systemctl restart ufw
systemctl enable ufw
ufw reload
ufw enable
ufw status
tailscale ip -4

