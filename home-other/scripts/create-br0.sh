#!/bin/bash

ip link add name br0 type bridge

ip tuntap add dev br0tap0 mode tap
ip link set dev br0tap0 master br0

#ip link set dev enp3s0 master br0


