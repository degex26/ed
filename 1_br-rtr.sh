enable
configure terminal
hostname br-rtr.au-team.irpo
ip domain-name au-team.irpo

interface e1
 ip address 172.16.40.2/28
 ip nat outside
 exit

interface e2
 ip address 192.168.2.1/28
 ip nat inside
 exit

port te1
 service-instance te1/br-net
  encapsulation untagged
  connect ip interface e2
 exit

ip route 0.0.0.0/0 172.16.40.1

ip nat pool nat 192.168.2.1-192.168.2.14
ip nat source dynamic inside-to-outside pool nat overload interface e1

interface tunnel.1
 ip add 192.168.10.2/30
 ip tunnel 172.16.40.2 172.16.30.2 mode gre
 ip ospf authentication
 ip ospf authentication-key P@$$word
 exit

router ospf 1
 network 192.168.10.0/30 area 0.0.0.0
 network 192.168.2.0/28 area 0.0.0.0
 passive-interface default
 no passive-interface tunnel.1
 exit

username net_admin
password P@ssw0rd
role admin

ntp timezone asia/novosibirsk
ntp server 172.16.40.1

write memory
