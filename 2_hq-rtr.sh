enable
configure terminal

security-profile 0
 rule 0 permit tcp any any eq 22
 security 0

ip nat source static tcp 192.168.113.2 80 172.16.30.2 8080
ip nat source static tcp 192.168.113.2 2026 172.16.30.2 2026

write memory
