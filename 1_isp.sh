#!/bin/bash

apt-get update
apt-get install -y wget curl nftables chrony

timedatectl set-timezone Asia/Novosibirsk
hostnamectl set-hostname ISP.au-team.irpo

mkdir -p /etc/net/ifaces/ens18
cat <<EOF > /etc/net/ifaces/ens18/options
BOOTPROTO=dhcp
TYPE=eth
DISABLED=no
NM_CONTROLLED=no
EOF

mkdir -p /etc/net/ifaces/ens19 /etc/net/ifaces/ens20
echo 'TYPE=eth' > /etc/net/ifaces/ens19/options
echo 'TYPE=eth' > /etc/net/ifaces/ens20/options
echo "172.16.30.1/28" > /etc/net/ifaces/ens19/ipv4address
echo "172.16.40.1/28" > /etc/net/ifaces/ens20/ipv4address
systemctl restart network

echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf

cat <<'EOF' > /etc/nftables/nftables.nft
#!/usr/sbin/nft -f
flush ruleset
table ip nat {
 chain postrouting {
  type nat hook postrouting priority srcnat
  oifname "ens18" masquerade
 }
}
EOF
systemctl enable --now nftables

cat <<EOF >> /etc/chrony.conf
local stratum 5
allow 0.0.0.0/0
EOF
systemctl restart chronyd
