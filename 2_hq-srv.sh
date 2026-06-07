#!/bin/bash

apt-get update
apt-get install -y nfs-server mdadm httpd2 apache2-mod_php8.1 php8.1 php8.1-mysqlnd mariadb-server dnsmasq

mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
mkfs.ext4 /dev/md0
mkdir -p /raid
mount /dev/md0 /raid
mdadm --detail /dev/md0 > /etc/mdadm.conf
echo '/dev/md0 /raid ext4 defaults 0 0' >> /etc/fstab

mkdir -p /raid/nfs
chmod 777 /raid/nfs
echo "/raid/nfs 192.168.1.32/27(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -rav
systemctl enable --now nfs-server

cat <<'EOF' > /etc/dnsmasq.conf
no-resolv
no-poll
no-hosts
server=77.88.8.7
server=8.8.8.8
cache-size=1000
all-servers
no-negcache
host-record=hq-rtr.au-team.irpo,192.168.1.1
host-record=hq-srv.au-team.irpo,192.168.1.2
host-record=hq-cli.au-team.irpo,192.168.1.34
address=/br-rtr.au-team.irpo/192.168.2.1
address=/br-srv.au-team.irpo/192.168.2.2
address=/docker.au-team.irpo/172.16.1.1
address=/web.au-team.irpo/172.16.2.1
EOF
systemctl enable --now dnsmasq

systemctl enable --now mariadb
mysql -u root <<EOT
CREATE DATABASE webdb;
CREATE USER 'web'@'localhost' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL PRIVILEGES ON webdb.* TO 'web'@'localhost';
FLUSH PRIVILEGES;
EOT

systemctl enable --now httpd2

mkdir -p /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
if [ -f /mnt/cdrom/web/dump.sql ]; then
  mysql -u root webdb < /mnt/cdrom/web/dump.sql
fi
cp /mnt/cdrom/web/index.php /var/www/html/ 2>/dev/null
cp /mnt/cdrom/web/logo.png /var/www/html/ 2>/dev/null
chown -R apache2:apache2 /var/www/html/
chmod -R 755 /var/www/html/

systemctl restart httpd2
