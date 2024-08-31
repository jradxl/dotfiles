#!/bin/bash

### Articles
#https://serverfault.com/questions/1119402/ubuntu-22-no-acpi-dmar-table-found-iommu-either-disabled-in-bios-or-not-support
#dmesg | grep -e DMAR -e IOMMU
#https://luna.oracle.com/lab/1671b073-895c-4800-bd60-cfe1f445074c/steps
#https://libvirt.org/formatdomain.html#iommu-devices
#https://developer.ibm.com/tutorials/compiling-libvirt-and-qemu/


apt install qemu-system-x86


# WILL INSTALL
#cpu-checker ipxe-qemu ipxe-qemu-256k-compat-efi-roms libaio1t64 libcacard0 libdaxctl1 libfdt1
#libiscsi7 libndctl6 libpmem1 libpmemobj1 librados2 librbd1 librdmacm1t64 libslirp0 libspice-server1
#liburing2 libusbredirparser1t64 libvirglrenderer1 msr-tools ovmf qemu-block-extra qemu-system-common
#qemu-system-data qemu-system-gui qemu-system-modules-opengl qemu-system-modules-spice qemu-system-x86
#qemu-utils seabios


#apt list --installed | grep qemu

#ipxe-qemu-256k-compat-efi-roms/noble,noble,now 1.0.0+git-20150424.a25a16d-0ubuntu4 all [installed,automatic]
#ipxe-qemu/noble,noble,now 1.21.1+git-20220113.fbbdc3926-0ubuntu1 all [installed,automatic]
#qemu-block-extra/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]
#qemu-system-common/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]
#qemu-system-data/noble,noble,now 1:8.2.1+ds-1ubuntu1 all [installed,automatic]
#qemu-system-gui/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]
#qemu-system-modules-opengl/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]
#qemu-system-modules-spice/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]
#qemu-system-x86/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed]
#qemu-utils/noble,now 1:8.2.1+ds-1ubuntu1 amd64 [installed,automatic]

echo ""
echo "KVM Version:"
kvm --version
##Command 'kvm' not found, but can be installed with: apt install qemu-system-x86

echo ""
echo "Qemu-KVM Service Status:"
systemctl status --no-pager -l qemu-kvm.service

