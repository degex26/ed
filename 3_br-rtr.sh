enable
configure terminal

access-list 100 permit tcp any any eq 22
access-list 100 permit tcp any any eq 80
access-list 100 permit icmp any any
access-list 100 deny ip any any log

interface e1
 ip access-group 100 in
 ip access-group 100 out
 exit

interface e2
 ip access-group 100 in
 ip access-group 100 out
 exit

crypto ikev2 proposal GOST-PROPOSAL
 encryption gost28147
 integrity gost3411
 group 5
 exit

crypto ikev2 policy GOST-POLICY
 proposal GOST-PROPOSAL
 exit

crypto ikev2 keyring GOST-KEYRING
 peer HQ-RTR
  address 172.16.1.2
  pre-shared-key P@ssw0rd
 exit
 exit

crypto ikev2 profile GOST-PROFILE
 match identity remote address 172.16.1.2
 authentication remote pre-share
 authentication local pre-share
 keyring local GOST-KEYRING
 exit

crypto ipsec transform-set GOST-TRANSFORM esp-gost28147 esp-gost3411
 mode tunnel

crypto ipsec profile GOST-PROFILE
 set transform-set GOST-TRANSFORM
 set ikev2-profile GOST-PROFILE
 exit

interface tunnel.1
 tunnel protection ipsec profile GOST-PROFILE
 exit

write memory