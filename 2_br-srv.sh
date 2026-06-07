#!/bin/bash

apt-get update && apt-get install -y docker-engine docker-compose ansible sshpass
systemctl enable --now docker

mkdir -p /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
if [ -f /mnt/cdrom/docker/site_latest.tar ]; then
  docker load -i /mnt/cdrom/docker/site_latest.tar
  docker load -i /mnt/cdrom/docker/mariadb_latest.tar
fi

mkdir -p /usr/docker
cat <<'EOF' > /usr/docker/docker-compose.yml
services:
  testapp:
    image: site:latest
    container_name: testapp
    restart: always
    ports:
      - "8080:8000"
    environment:
      DB_TYPE: maria
      DB_HOST: db
      DB_NAME: testdb
      DB_PORT: 3306
      DB_USER: test
      DB_PASS: P@ssw0rd
    depends_on:
      - db
  db:
    image: mariadb:10.11
    container_name: db
    restart: always
    environment:
      MARIADB_DATABASE: testdb
      MARIADB_USER: test
      MARIADB_PASSWORD: P@ssw0rd
      MARIADB_ROOT_PASSWORD: rootpass
EOF

cd /usr/docker && docker compose up -d

cat <<'EOF' > /etc/ansible/hosts
[hq]
hq-srv ansible_port=2026 ansible_host=192.168.1.2 ansible_user=sshuser ansible_ssh_pass=P@ssw0rd ansible_python_interpreter=/usr/bin/python3
hq-cli ansible_host=192.168.1.34 ansible_user=user ansible_ssh_pass=resu ansible_python_interpreter=/usr/bin/python3
[routers]
hq-rtr ansible_host=192.168.1.1 ansible_user=admin ansible_password=admin ansible_connection=network_cli ansible_network_os=ios ansible_python_interpreter=/usr/bin/python3
br-rtr ansible_host=192.168.2.1 ansible_user=admin ansible_password=admin ansible_connection=network_cli ansible_network_os=ios ansible_python_interpreter=/usr/bin/python3
EOF