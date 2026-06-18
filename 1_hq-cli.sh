#!/bin/bash

apt-get update
apt-get install -y chrony

timedatectl set-timezone Asia/Novosibirsk
hostnamectl set-hostname hq-cli.au-team.irpo

echo 'NM_CONTROLLED=no' >> /etc/net/ifaces/ens18/options
echo 'DISABLED=no' >> /etc/net/ifaces/ens18/options
systemctl restart network

echo "server 172.16.30.1 iburst" > /etc/chrony.conf
systemctl restart chronyd
