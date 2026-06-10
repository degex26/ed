#!/bin/bash
# ============================================
# МОДУЛЬ 3 — HQ-SRV
# (ГОСТ, принт-сервер, мониторинг, бэкапы, fail2ban, логи)
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

# 3. Сертификаты ГОСТ
apt-get install -y gost-engine openssl-gost-engine
openssl req -x509 -newkey gost2012_256 -pkeyopt dgst:streebog256 \
  -keyout /etc/ssl/private/hq-srv.key \
  -out /etc/ssl/certs/hq-srv.crt \
  -days 365 -nodes \
  -subj "/CN=hq-srv.au-team.irpo"
cat <<EOF >> /etc/httpd2/conf/extra/ssl.conf
SSLCertificateFile /etc/ssl/certs/hq-srv.crt
SSLCertificateKeyFile /etc/ssl/private/hq-srv.key
SSLCipherSuite GOST2012
EOF
systemctl restart httpd2

# 4. Принт-сервер CUPS
apt-get install -y cups cups-client
systemctl enable --now cups
cat <<EOF > /etc/cups/cupsd.conf
Listen 0.0.0.0:631
BrowseLocalProtocols all
<Location />
  Order allow,deny
  Allow all
</Location>
<Location /admin>
  AuthType Basic
  Require user @SYSTEM
  Order allow,deny
  Allow all
</Location>
EOF
systemctl restart cups
lpadmin -p VirtualPDF -E -v file:/dev/null -m drv:///sample.drv/generic.ppd

# 5. Мониторинг Prometheus + Grafana
useradd --no-create-home --shell /bin/false prometheus
mkdir -p /etc/prometheus /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar -xzf prometheus-2.45.0.linux-amd64.tar.gz
cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'nodes'
    static_configs:
      - targets: ['192.168.1.2:9100', '192.168.2.2:9100']
EOF
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target
[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus
[Install]
WantedBy=default.target
EOF
systemctl enable --now prometheus
apt-get install -y grafana
systemctl enable --now grafana-server
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar -xzf node_exporter-1.6.0.linux-amd64.tar.gz
cp node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
useradd --no-create-home --shell /bin/false node_exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=default.target
EOF
systemctl enable --now node_exporter

# 6. Резервное копирование Borg
apt-get install -y borgbackup
mkdir -p /backup
borg init --encryption=none /backup/borg-repo
cat <<'EOF' > /usr/local/bin/backup.sh
#!/bin/bash
DATE=$(date +%Y-%m-%d_%H-%M-%S)
borg create --stats --progress \
  /backup/borg-repo::"backup-$DATE" \
  /etc /var/www /raid/nfs --exclude /var/cache
borg prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 /backup/borg-repo
EOF
chmod +x /usr/local/bin/backup.sh
/usr/local/bin/backup.sh
echo "0 2 * * * root /usr/local/bin/backup.sh" >> /etc/crontab

echo "=== Настройка HQ-SRV завершена ==="