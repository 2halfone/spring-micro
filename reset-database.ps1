# Script PowerShell per forzare la reinizializzazione del database PostgreSQL
# Rimuove i volumi esistenti per permettere al init script di eseguire

Write-Host "🔄 Resetting PostgreSQL database for fresh initialization..." -ForegroundColor Yellow

# Stop tutti i container
Write-Host "Stopping all containers..." -ForegroundColor Blue
docker-compose down

# Rimuovi i volumi per forzare reinizializzazione
Write-Host "Removing PostgreSQL and Redis volumes..." -ForegroundColor Blue
docker volume rm springmon-microservices_postgres_data 2>$null
docker volume rm springmon-microservices_redis_data 2>$null

# Pulisci anche immagini orfane
Write-Host "Cleaning up orphaned containers and images..." -ForegroundColor Blue
docker system prune -f

Write-Host "✅ Database reset completed. Now starting fresh containers..." -ForegroundColor Green

# Riavvia i servizi
docker-compose up -d postgres redis

Write-Host "⏳ Waiting for PostgreSQL to initialize..." -ForegroundColor Yellow
Start-Sleep 30

# Verifica che i database siano stati creati
Write-Host "🔍 Checking database creation..." -ForegroundColor Blue
docker exec springmon-postgres psql -U springmon_user -d springmon -c "\l"

Write-Host "✅ PostgreSQL reset and reinitialization completed!" -ForegroundColor Green
Write-Host "Now you can start the application services:" -ForegroundColor Cyan
Write-Host "docker-compose up -d" -ForegroundColor White
