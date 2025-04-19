#!/bin/bash

# Start Windmill di background
windmill --host 127.0.0.1 --port 8000 &

# Start HAProxy di foreground
haproxy -f /etc/haproxy/haproxy.cfg -db
