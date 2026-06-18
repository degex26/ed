#!/bin/bash

mkdir -p /mnt/nfs
mount 192.168.113.2:/raid/nfs /mnt/nfs
echo "192.168.113.2:/raid/nfs /mnt/nfs nfs defaults,_netdev 0 0" >> /etc/fstab

echo "search au-team.irpo" > /etc/resolv.conf
echo "nameserver 192.168.113.2" >> /etc/resolv.conf

# Яндекс Браузер
apt-get update
apt-get install -y yandex-browser-stable
