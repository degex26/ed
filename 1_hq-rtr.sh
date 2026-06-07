enable
configure terminal
hostname hq-rtr.au-team.irpo

interface e1
 ip address 172.16.1.2/28
 ip nat outside
 exit
interface e2
 ip address 192.168.1.1/27
 ip nat inside
 exit
interface e3
 ip address 192.168.1.33/27
 ip nat inside
 exit

ip route 0.0.0.0/0 172.16.1.1

ip nat pool nat 192.168.1.1-192.168.1.30,192.168.1.33-192.168.1.62
ip nat source dynamic inside-to-outside pool nat overload interface e1

ntp timezone asia/novosibirsk

write memory
