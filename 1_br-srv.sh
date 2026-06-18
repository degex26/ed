#!/bin/bash

apt-get update
apt-get install -y chrony

timedatectl set-timezone Asia/Novosibirsk
hostnamectl set-hostname br-srv.au-team.irpo

echo 'BOOTPROTO=static' > /etc/net/ifaces/ens18/options
echo "192.168.2.2/28" > /etc/net/ifaces/ens18/ipv4address
echo "default via 192.168.2.1" > /etc/net/ifaces/ens18/ipv4route
systemctl restart network

useradd -s /bin/bash -u 2012 sshuser
echo "sshuser:P@ssw0rd" | chpasswd
gpasswd -a sshuser wheel
echo 'sshuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

sed -i 's/#Port 22/Port 2026/' /etc/openssh/sshd_config
echo "AllowUsers sshuser" >> /etc/openssh/sshd_config
echo "Authorized access only" > /etc/openssh/banner
systemctl restart sshd

echo "server 172.16.40.1 iburst" > /etc/chrony.conf
systemctl restart chronyd
