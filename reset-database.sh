#!/bin/bash
# Script per forzare la reinizializzazione del database PostgreSQL
# Rimuove i volumi esistenti per permettere al init script di eseguire

echo "🔄 Resetting PostgreSQL database for fresh initialization..."

# Stop tutti i container
echo "Stopping all containers..."
docker-compose down

# Rimuovi i volumi per forzare reinizializzazione
echo "Removing PostgreSQL and Redis volumes..."
docker volume rm springmon-microservices_postgres_data 2>/dev/null || true
docker volume rm springmon-microservices_redis_data 2>/dev/null || true

# Pulisci anche immagini orfane
echo "Cleaning up orphaned containers and images..."
docker system prune -f

echo "✅ Database reset completed. Now starting fresh containers..."

# Riavvia i servizi
docker-compose up -d postgres redis

echo "⏳ Waiting for PostgreSQL to initialize..."
sleep 30

# Verifica che i database siano stati creati
echo "🔍 Checking database creation..."
docker exec springmon-postgres psql -U springmon_user -d springmon -c "\l"

echo "✅ PostgreSQL reset and reinitialization completed!"
echo "Now you can start the application services:"
echo "docker-compose up -d"
