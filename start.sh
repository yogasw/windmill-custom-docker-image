#!/bin/bash

# Write NGINX configuration at runtime
cat <<EOF > /etc/nginx/conf.d/default.conf
log_format json_logs escape=json '{"time":"$time_local","ip":"$remote_addr","path":"$uri","params":"$args","body":"$request_body","status":"$status","user_agent":"$http_user_agent"}';

access_log /dev/stdout json_logs;
error_log /dev/stderr;

server {
  listen 80;
  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_request_buffering off;
    proxy_http_version 1.1;
  }
}
EOF

# Start nginx and windmill
nginx
exec windmill --host 127.0.0.1 --port 8080
