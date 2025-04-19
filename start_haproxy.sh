systemctl start haproxy


# Jalankan Windmill secara internal (tidak diekspos ke luar container)
exec windmill --host 127.0.0.1 --port 8000
