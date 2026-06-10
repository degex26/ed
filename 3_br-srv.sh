#!/bin/bash
# ============================================
# МОДУЛЬ 3 — BR-SRV
# (импорт пользователей, Ansible, логи, fail2ban)
# ============================================

apt-get update

# 1. Логирование и ротация
apt-get install -y logrotate
cat <<EOF > /etc/logrotate.d/system
/var/log/messages
/var/log/secure {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF
echo "*.* @@192.168.1.2:514" >> /etc/rsyslog.conf
systemctl restart rsyslog

# 2. Защита SSH (fail2ban)
apt-get install -y fail2ban
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
[sshd]
enabled = true
port = 2026
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
systemctl enable --now fail2ban

# 3. Импорт пользователей в домен
kinit administrator@AU-TEAM.IRPO <<< "P@ssw0rd!"
for i in 1 2 3 4 5; do
    samba-tool user create "user$i" "P@ssw0rd$i" --must-change-at-next-login=no
done
samba-tool group add IT
samba-tool group add Бухгалтерия
samba-tool group addmembers IT user1,user2
samba-tool group addmembers Бухгалтерия user3,user4

# 4. Ansible инвентаризация
apt-get install -y ansible
cat <<EOF > /tmp/gather_facts.yml
---
- name: Сбор инвентаризации
  hosts: all
  become: yes
  tasks:
    - name: Сбор информации
      setup:
      register: facts
    - name: Сохранение фактов
      copy:
        content: "{{ facts | to_nice_json }}"
        dest: "/tmp/inventory_{{ inventory_hostname }}.json"
EOF
ansible-playbook -i /etc/ansible/hosts /tmp/gather_facts.yml

echo "=== Настройка BR-SRV завершена ==="