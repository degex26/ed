#!/bin/bash

mkdir -p /mnt/nfs
mount 192.168.1.2:/raid/nfs /mnt/nfs
echo "192.168.1.2:/raid/nfs /mnt/nfs nfs defaults,_netdev 0 0" >> /etc/fstab

echo "search au-team.irpo" > /etc/resolv.conf
echo "nameserver 192.168.2.2" >> /etc/resolv.conf
echo "nameserver 192.168.1.2" >> /etc/resolv.conf