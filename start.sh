#!/bin/bash

# Tulis konfigurasi nginx saat runtime
cat <<EOF > /etc/nginx/conf.d/default.conf
log_format json_logs escape=json '{"timestamp":"\$time_iso8601","level":"INFO","message":"INBOUND_REQUEST","status":"\$status","path":"\$uri","method":"\$request_method","ip":"\$remote_addr","params":"\$args","body":"\$request_body","user_agent":"\$http_user_agent"}';

access_log /dev/stdout json_logs;
error_log /dev/stderr;

server {
  listen 80;
  
  # Log only for specific /api/w/admins/jobs/run/f/u/, /api/w/:project/jobs/run, or any /api/r path
  location ~ ^/api/w/admins/jobs/run/f/u/|^/api/w/[^/]+/jobs/run|^/api/r/ {
    access_log /dev/stdout json_logs;
    proxy_pass http://127.0.0.1:8000;
    proxy_pass_request_headers on;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_request_buffering off;
    proxy_http_version 1.1;
  }

  # Disable logging for other routes
  location / {
    access_log off;
    proxy_pass http://127.0.0.1:8000;
    proxy_pass_request_headers on;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_request_buffering off;
    proxy_http_version 1.1;
  }
}
EOF

# Jalankan nginx
nginx

sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h
sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c
sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c

# Jalankan Windmill secara internal (tidak diekspos ke luar container)
exec windmill --host 127.0.0.1 --port 8000
