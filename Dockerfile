FROM ghcr.io/windmill-labs/windmill:main

USER root

# Install NGINX
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Remove default config
RUN rm /etc/nginx/sites-enabled/default

# Add custom NGINX config
RUN echo '\
log_format json_logs escape=json '\''{\
  "time":"$time_local",\
  "ip":"$remote_addr",\
  "path":"$uri",\
  "params":"$args",\
  "body":"$request_body",\
  "status":"$status",\
  "user_agent":"$http_user_agent"\
}'\'';\n\
access_log /var/log/nginx/access.log json_logs;\n\
server {\n\
  listen 80;\n\
  location / {\n\
    proxy_pass http://127.0.0.1:8080;\n\
    proxy_set_header Host $host;\n\
    proxy_set_header X-Real-IP $remote_addr;\n\
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
    proxy_request_buffering off;\n\
    proxy_http_version 1.1;\n\
  }\n\
}' > /etc/nginx/conf.d/default.conf

# Set environment variables
ENV JSON_FMT=true \
    DISABLE_RESPONSE_LOGS=false \
    CREATE_WORKSPACE_REQUIRE_SUPERADMIN=true

# Expose port for external traffic (NGINX)
EXPOSE 80

# Jalankan NGINX dan Windmill
CMD windmill && service nginx start

# CMD ["windmill", "--host", "127.0.0.1", "--port", "8080"]
