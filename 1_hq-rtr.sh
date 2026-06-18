enable
configure terminal
hostname hq-rtr.au-team.irpo
ip domain-name au-team.irpo

interface e1
 ip address 172.16.30.2/28
 ip nat outside
 exit

interface e2
 ip address 192.168.113.1/27
 ip nat inside
 exit

interface e3
 ip address 192.168.213.1/27
 ip nat inside
 exit

interface e4
 ip address 192.168.813.1/29
 ip nat inside
 exit

port te1
 service-instance te1/srv-net
  encapsulation dot1q 113
  rewrite pop 1
  connect ip interface e2
 exit
 service-instance te1/cli-net
  encapsulation dot1q 213
  rewrite pop 1
  connect ip interface e3
 exit
 service-instance te1/management
  encapsulation dot1q 813
  rewrite pop 1
  connect ip interface e4
 exit

ip route 0.0.0.0/0 172.16.30.1

ip nat pool nat 192.168.113.1-192.168.113.30,192.168.213.1-192.168.213.30,192.168.813.1-192.168.813.6
ip nat source dynamic inside-to-outside pool nat overload interface e1

ip pool dhcp 1
 range 192.168.213.2-192.168.213.30
 mask 255.255.255.224
 gateway 192.168.213.1
 dns 192.168.113.2
 domain-name au-team.irpo
 exit

dhcp-server 1
 pool dhcp 1
 interface e3
 exit

interface tunnel.1
 ip add 192.168.10.1/30
 ip tunnel 172.16.30.2 172.16.40.2 mode gre
 ip ospf authentication
 ip ospf authentication-key P@$$word
 exit

router ospf 1
 network 192.168.10.0/30 area 0.0.0.0
 network 192.168.113.0/27 area 0.0.0.0
 network 192.168.213.0/27 area 0.0.0.0
 network 192.168.813.0/29 area 0.0.0.0
 passive-interface default
 no passive-interface tunnel.1
 exit

username net_admin
password P@ssw0rd
role admin

ntp timezone asia/novosibirsk
ntp server 172.16.30.1

write memory
