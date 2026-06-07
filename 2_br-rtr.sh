enable
configure terminal
ip nat source static tcp 192.168.2.2 8080 172.16.2.2 8080
ip nat source static tcp 192.168.2.2 2026 172.16.2.2 2026
write memory
