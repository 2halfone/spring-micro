#!/usr/bin/env pwsh

# SpringMon Microservices - Quick Deployment Script
# This script helps you get the microservices running quickly

Write-Host "=== SpringMon Microservices Quick Deploy ===" -ForegroundColor Cyan
Write-Host ""

$services = @("auth-service", "user-service", "gateway-service")

Write-Host "🔍 Checking deployment readiness..." -ForegroundColor Yellow
Write-Host ""

# Check if JAR files exist
$allReady = $true
foreach ($service in $services) {
    $jarFile = "$service\target\$service-1.0.0-SNAPSHOT.jar"
    if (Test-Path $jarFile) {
        $size = [math]::Round((Get-Item $jarFile).Length / 1MB, 1)
        Write-Host "✅ $service - JAR ready ($size MB)" -ForegroundColor Green
    } else {
        Write-Host "❌ $service - JAR missing" -ForegroundColor Red
        $allReady = $false
    }
}

if (-not $allReady) {
    Write-Host ""
    Write-Host "❌ Some JARs are missing. Please run compilation first:" -ForegroundColor Red
    Write-Host "   mvnw clean package -DskipTests" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎯 All services ready for deployment!" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Choose deployment method:" -ForegroundColor Yellow
Write-Host "   1. Docker Compose (Recommended)" -ForegroundColor White
Write-Host "   2. Individual JARs" -ForegroundColor White
Write-Host "   3. Development Mode (Maven)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🐳 Starting Docker Compose deployment..." -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path "docker-compose.yml") {
            Write-Host "Starting services with Docker Compose..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Command: docker-compose up -d" -ForegroundColor Gray
            Write-Host ""
            Write-Host "This will start:" -ForegroundColor Green
            Write-Host "   • PostgreSQL database" -ForegroundColor White
            Write-Host "   • Auth Service (port 8082)" -ForegroundColor White
            Write-Host "   • User Service (port 8083)" -ForegroundColor White
            Write-Host "   • Gateway Service (port 8080)" -ForegroundColor White
            Write-Host ""
            Write-Host "Run the command above to start all services." -ForegroundColor Yellow
        } else {
            Write-Host "❌ docker-compose.yml not found" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "☕ Starting with individual JARs..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "You'll need to run each service in a separate terminal:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Terminal 1 (Auth Service):" -ForegroundColor Green
        Write-Host "   cd auth-service" -ForegroundColor Gray
        Write-Host "   java -jar target\auth-service-1.0.0-SNAPSHOT.jar" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Terminal 2 (User Service):" -ForegroundColor Green
        Write-Host "   cd user-service" -ForegroundColor Gray
        Write-Host "   java -jar target\user-service-1.0.0-SNAPSHOT.jar" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Terminal 3 (Gateway Service):" -ForegroundColor Green
        Write-Host "   cd gateway-service" -ForegroundColor Gray
        Write-Host "   java -jar target\gateway-service-1.0.0-SNAPSHOT.jar" -ForegroundColor Gray
        Write-Host ""
        Write-Host "⚠️  Note: You'll need PostgreSQL running separately." -ForegroundColor Yellow
    }
    
    "3" {
        Write-Host ""
        Write-Host "🔧 Starting in Development Mode..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Run each service in a separate terminal:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Terminal 1 (Auth Service):" -ForegroundColor Green
        Write-Host "   cd auth-service" -ForegroundColor Gray
        Write-Host "   ..\mvnw.cmd spring-boot:run" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Terminal 2 (User Service):" -ForegroundColor Green
        Write-Host "   cd user-service" -ForegroundColor Gray
        Write-Host "   ..\mvnw.cmd spring-boot:run" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Terminal 3 (Gateway Service):" -ForegroundColor Green
        Write-Host "   cd gateway-service" -ForegroundColor Gray
        Write-Host "   ..\mvnw.cmd spring-boot:run" -ForegroundColor Gray
        Write-Host ""
        Write-Host "⚠️  Note: You'll need PostgreSQL running separately." -ForegroundColor Yellow
    }
    
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📝 Important Notes:" -ForegroundColor Yellow
Write-Host "   • Make sure PostgreSQL is running" -ForegroundColor White
Write-Host "   • Database will be created automatically" -ForegroundColor White
Write-Host "   • Check logs for any startup issues" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "   • Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "   • Auth Service: http://localhost:8082" -ForegroundColor White
Write-Host "   • User Service: http://localhost:8083" -ForegroundColor White
Write-Host ""

Write-Host "🧪 Test Endpoints:" -ForegroundColor Cyan
Write-Host "   • Health: GET http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host "   • Register: POST http://localhost:8080/api/auth/register" -ForegroundColor White
Write-Host "   • Login: POST http://localhost:8080/api/auth/login" -ForegroundColor White
Write-Host ""

Write-Host "✅ Deployment guide complete!" -ForegroundColor Green
