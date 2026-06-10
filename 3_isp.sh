#!/bin/bash
# ============================================
# МОДУЛЬ 3 — ISP (логирование, ротация)
# ============================================

apt-get update
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
    sharedscripts
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2>/dev/null\` 2>/dev/null || true
    endscript
}
EOF

# Удалённое логирование на HQ-SRV
echo "*.* @@192.168.1.2:514" >> /etc/rsyslog.conf
systemctl restart rsyslog

echo "=== Настройка ISP завершена ==="