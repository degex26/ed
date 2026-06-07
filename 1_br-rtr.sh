enable
configure terminal
hostname br-rtr.au-team.irpo

interface e1
 ip address 172.16.2.2/28
 ip nat outside
 exit
interface e2
 ip address 192.168.2.1/28
 ip nat inside
 exit

ip route 0.0.0.0/0 172.16.2.1

ip nat pool nat 192.168.2.1-192.168.2.14
ip nat source dynamic inside-to-outside pool nat overload interface e1

ntp timezone asia/novosibirsk

write memory
