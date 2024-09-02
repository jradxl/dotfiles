#!/bin/bash

## Example to DD and image to USB drive

#ISONAME=manjaro-gnome-immutable-2024.08.01-x86_64.iso
#ISONAME=arkanelinux-arkdep-2024.08.18-uefi_only.iso

sudo  dd  if="$ISONAME"  of=/dev/sde bs=1M status=progress
