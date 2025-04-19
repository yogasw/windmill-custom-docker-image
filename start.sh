#!/bin/bash

# Tulis konfigurasi nginx saat runtime
cat <<EOF > /etc/nginx/conf.d/default.conf
log_format json_logs escape=json '{
  "time":"\$time_local",
  "ip":"\$remote_addr",
  "path":"\$uri",
  "params":"\$args",
  "body":"\$request_body",
  "status":"\$status",
  "user_agent":"\$http_user_agent"
}';

access_log /var/log/nginx/access.log json_logs;

server {
  listen 80;
  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_request_buffering off;
    proxy_http_version 1.1;
  }
}
EOF

# Batasi akses ke port 8000 dari luar container (opsional)
iptables -A INPUT -p tcp --dport 8000 ! -s 127.0.0.1 -j DROP
iptables -A INPUT -p tcp -s 127.0.0.1 --dport 8000 -j ACCEPT

# Jalankan nginx
nginx

# Jalankan Windmill secara internal (tidak diekspos ke luar container)
exec windmill --host 127.0.0.1 --port 8080
