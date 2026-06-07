#!/bin/bash

timedatectl set-timezone Asia/Novosibirsk
hostnamectl set-hostname hq-srv.au-team.irpo

echo 'BOOTPROTO=static' > /etc/net/ifaces/ens18/options
echo "192.168.1.2/27" > /etc/net/ifaces/ens18/ipv4address
echo "default via 192.168.1.1" > /etc/net/ifaces/ens18/ipv4route
systemctl restart network

useradd -s /bin/bash -u 2026 sshuser
echo "sshuser:P@ssw0rd" | chpasswd
gpasswd -a sshuser wheel
echo 'sshuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

sed -i 's/#Port 22/Port 2026/' /etc/openssh/sshd_config
echo "AllowUsers sshuser" >> /etc/openssh/sshd_config
echo "Authorized access only" > /etc/openssh/banner
systemctl restart sshd