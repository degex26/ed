
============================================
ISP
============================================

hostnamectl
ip a
ip route
cat /proc/sys/net/ipv4/ip_forward
nft list ruleset | grep -A10 "chain postrouting"
ping -c 3 8.8.8.8
systemctl status chronyd
chronyc sources
timedatectl | grep "Time zone"


============================================
HQ-RTR (EcoRouter)
============================================

show ip interface brief
show ip route
show ip nat translations
show ntp associations


============================================
BR-RTR (EcoRouter)
============================================

show ip interface brief
show ip route
show ip nat translations
show ntp associations


============================================
HQ-SRV
============================================

hostnamectl
ip a
ip route | grep default
id sshuser
sudo -l | grep NOPASSWD
ss -tln | grep 2026
cat /etc/openssh/banner
ping -c 3 8.8.8.8
ping -c 3 192.168.1.1
chronyc sources
timedatectl | grep "Time zone"


============================================
BR-SRV
============================================

hostnamectl
ip a
ip route | grep default
id sshuser
sudo -l | grep NOPASSWD
ss -tln | grep 2026
cat /etc/openssh/banner
ping -c 3 8.8.8.8
ping -c 3 192.168.2.1
chronyc sources
timedatectl | grep "Time zone"


============================================
HQ-CLI
============================================

hostnamectl
ip a
ping -c 3 192.168.1.2
ping -c 3 8.8.8.8
ssh -p 2026 sshuser@192.168.1.2
chronyc sources
timedatectl | grep "Time zone"


============================================
МОДУЛЬ 2 — дополнительные проверки
============================================

=== ISP ===
systemctl status nginx
cat /etc/nginx/.htpasswd

=== HQ-RTR ===
show ip nat translations

=== BR-RTR ===
show ip nat translations

=== HQ-SRV ===
cat /proc/mdstat
exportfs -v
systemctl status dnsmasq
systemctl status httpd2
mysql -u root -e "SHOW DATABASES;"

=== BR-SRV ===
docker ps -a
ansible all -m ping

=== HQ-CLI ===
mount | grep nfs
host web.au-team.irpo
curl -I http://web.au-team.irpo
yandex-browser --version
