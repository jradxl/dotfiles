#!/bin/bash

incus profile show userdata >/dev/null 2>/dev/null
if [[ "$?" -ne 0 ]]; then
    echo "Profile not found. Continuing..."
else
    incus profile delete userdata >/dev/null 2>/dev/null
    if [[ "$?" -ne 0 ]]; then
        echo "In use. Exiting..."
        exit 1
    fi
fi

sleep 2

incus profile list
sleep 2

incus profile create userdata
sleep 2

cat << EOF | incus profile set userdata cloud-init.user-data -
#cloud-config
users:
  - default
  - name: user1
    gecos: John user1
    shell: /bin/bash
    groups: users, sudo
    ssh_authorized_keys:
      - ssh-ed25519 AAAA-RUBBISH-DI1NTE5AAAAIKEPjlP6aM8c/SgnmlVljbpyYuIbBx71R96Qd/2Vvpm+ Incus
  - name: user2
    gecos: John user2
    shell: /bin/bash
    groups: users, sudo
    ssh_authorized_keys:
      - ssh-ed25519 AAAA-RUBBISH-DI1NTE5AAAAIKEPjlP6aM8c/SgnmlVljbpyYuIbBx71R96Qd/2Vvpm+ Incus
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
  - openssh-server
runcmd:
  - [touch, /run/john-was-here]
chpasswd:
  users:
    - {name: user1, password: secret99, type: text}
    - {name: user2, password: secret99, type: text}
  expire: true
ssh_pwauth: true
EOF

incus profile show userdata

