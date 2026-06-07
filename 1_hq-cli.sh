#!/bin/bash

timedatectl set-timezone Asia/Novosibirsk
hostnamectl set-hostname hq-cli.au-team.irpo

echo 'NM_CONTROLLED=no' >> /etc/net/ifaces/ens18/options
echo 'DISABLED=no' >> /etc/net/ifaces/ens18/options
systemctl restart network