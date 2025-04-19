FROM ghcr.io/windmill-labs/windmill:main

USER root

# Install nginx and iptables
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Remove default nginx config
RUN rm /etc/nginx/sites-enabled/default

# Set environment variables
ENV JSON_FMT=true \
    DISABLE_RESPONSE_LOGS=false \
    CREATE_WORKSPACE_REQUIRE_SUPERADMIN=true

# Copy external start.sh script into container
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose only nginx port to outside
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
