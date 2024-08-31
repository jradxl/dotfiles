#!/bin/bash

### Articles
#https://serverfault.com/questions/1119402/ubuntu-22-no-acpi-dmar-table-found-iommu-either-disabled-in-bios-or-not-support
#dmesg | grep -e DMAR -e IOMMU
#https://luna.oracle.com/lab/1671b073-895c-4800-bd60-cfe1f445074c/steps
#https://libvirt.org/formatdomain.html#iommu-devices
#https://developer.ibm.com/tutorials/compiling-libvirt-and-qemu/


# apt install libvirt-daemon-driver-qemu
# libtpms0 libvirt-daemon-driver-qemu libvirt-l10n libvirt0 swtpm swtpm-tools

## Typical Installation Requirement
apt install virt-manager virt-viewer

#  dmeventd gir1.2-gtk-vnc-2.0 gir1.2-libosinfo-1.0 gir1.2-libvirt-glib-1.0
#  gir1.2-spiceclientglib-2.0 gir1.2-spiceclientgtk-3.0 libburn4t64 libdevmapper-event1.02.1
#  libgtk-vnc-2.0-0 libgvnc-1.0-0 libisoburn1t64 libisofs6t64 liblvm2cmd2.03
#  libnss-mymachines libosinfo-1.0-0 libosinfo-l10n libphodav-3.0-0 libphodav-3.0-common
#  libspice-client-glib-2.0-8 libspice-client-gtk-3.0-5 libtpms0 libusbredirhost1t64
#  libvirt-clients libvirt-daemon libvirt-daemon-config-network
#  libvirt-daemon-config-nwfilter libvirt-daemon-driver-qemu libvirt-daemon-system
#  libvirt-daemon-system-systemd libvirt-glib-1.0-0 libvirt-glib-1.0-data libvirt-l10n
#  libvirt0 libxml2-utils lvm2 mdevctl osinfo-db python3-libvirt python3-libxml2
#  spice-client-glib-usb-acl-helper swtpm swtpm-tools systemd-container
#  thin-provisioning-tools virt-manager virt-viewer virtinst xorriso


echo ""
echo "Installing tools for Cloud Images"
echo ""

## To Allow Use of Cloud Images
# apt info    uvtool-libvirt
apt install uvtool-libvirt

#  cloud-image-utils dmeventd genisoimage libdevmapper-event1.02.1 liblvm2cmd2.03
#  libnss-mymachines libtpms0 libvirt-clients libvirt-daemon libvirt-daemon-config-network
#  libvirt-daemon-config-nwfilter libvirt-daemon-driver-qemu libvirt-daemon-system
#  libvirt-daemon-system-systemd libvirt-l10n libvirt0 libxml2-utils lvm2 mdevctl
#  python3-boto3 python3-botocore python3-bs4 python3-cssselect python3-html5lib
#  python3-jmespath python3-libvirt python3-lxml python3-s3transfer python3-simplestreams
#  python3-soupsieve python3-webencodings socat swtpm swtpm-tools systemd-container
#  thin-provisioning-tools ubuntu-cloudimage-keyring uvtool-libvirt


exit 0

