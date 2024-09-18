#!/bin/bash

# https://linuxize.com/post/how-to-list-and-delete-ufw-firewall-rules/

echo "Restarting and enabling OpenSSH by UFW..."

systemctl restart ufw
systemctl enable ufw
ufw allow OpenSSH
ufw reload
ufw enable
ufw status
tailscale ip -4
