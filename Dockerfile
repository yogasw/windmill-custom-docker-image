FROM ghcr.io/windmill-labs/windmill:main

USER root

# Install nginx and iptables
RUN apt-get update && apt-get install -y nginx iptables && rm -rf /var/lib/apt/lists/*

# Remove default nginx config
RUN rm /etc/nginx/sites-enabled/default

# Set environment variables
ENV JSON_FMT=true \
    DISABLE_RESPONSE_LOGS=false \
    CREATE_WORKSPACE_REQUIRE_SUPERADMIN=true

# Create start.sh at build time (with nginx config + iptables + app launch)
RUN echo '#!/bin/bash
# Write NGINX config dynamically
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

# Allow local-only access to port 8000
iptables -A INPUT -p tcp --dport 8000 ! -s 127.0.0.1 -j DROP
iptables -A INPUT -p tcp -s 127.0.0.1 --dport 8000 -j ACCEPT

# Start nginx in background
nginx

# Run windmill on internal-only port
exec windmill --host 127.0.0.1 --port 8080' > /start.sh && chmod +x /start.sh

# Expose only nginx port to outside
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
