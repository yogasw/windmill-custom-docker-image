
#!/bin/bash
set -e

# sample env
DATABASE_URL=postgres://postgres:changeme@localhost:5432/windmill?sslmode=disable
JSON_FMT=true
DISABLE_RESPONSE_LOGS=false
BASE_URL=http://154.90.49.247:8000
WM_IMAGE=ghcr.io/windmill-labs/windmill:main

# Jalankan kontainer PostgreSQL
docker run -d \
  --name windmill_db \
  -e POSTGRES_PASSWORD=changeme \
  -e POSTGRES_DB=windmill \
  -p 5432:5432 \
  -v windmill_db_data:/var/lib/postgresql/data \
  --health-cmd="pg_isready -U postgres" \
  --health-interval=10s \
  --health-timeout=5s \
  --health-retries=5 \
  postgres:14

WM_IMAGE="ghcr.io/windmill-labs/windmill:main"

# Jalankan kontainer Windmill Server
docker run -d \
  --name windmill_server \
  --link windmill_db:db \
  -e DATABASE_URL=postgres://postgres:changeme@db/windmill?sslmode=disable \
  -e MODE=server \
  -p 8000:8000 \
  --env-file .env \
  -p 2525:2525 \
  ${WM_IMAGE}

# Jalankan kontainer Windmill Worker
docker run -d \
  --name windmill_worker \
  --link windmill_db:db \
  -e DATABASE_URL=postgres://postgres:changeme@db/windmill?sslmode=disable \
  -e MODE=worker \
  -e WORKER_GROUP=default \
  ${WM_IMAGE}
