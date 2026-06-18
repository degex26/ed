#!/bin/bash

apt-get update
apt-get install -y nginx apache2-htpasswd

systemctl enable --now nginx

htpasswd -b -c /etc/nginx/.htpasswd WEB P@ssw0rd

cat <<'EOF' > /etc/nginx/sites-enabled.d/reverse.conf
server {
    listen 80;
    server_name web.au-team.irpo;
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    location / {
        proxy_pass http://172.16.30.2:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
server {
    listen 80;
    server_name docker.au-team.irpo;
    location / {
        proxy_pass http://172.16.40.2:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

nginx -t && systemctl restart nginx
