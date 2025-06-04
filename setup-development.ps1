#!/usr/bin/env pwsh

Write-Host "SpringMon Microservices - Development Setup" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$baseDir = Get-Location

Write-Host "`n📋 Project Status Check:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

# Check Java installation
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java: $($javaVersion.Line)" -ForegroundColor Green
} catch {
    Write-Host "❌ Java: NOT FOUND" -ForegroundColor Red
    Write-Host "   Please install Java 17 or later" -ForegroundColor Yellow
    exit 1
}

# Check Maven installation
try {
    $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven"
    Write-Host "✅ Maven: $($mavenVersion.Line)" -ForegroundColor Green
    $mavenAvailable = $true
} catch {
    Write-Host "⚠️  Maven: NOT FOUND" -ForegroundColor Yellow
    Write-Host "   Maven is required to build and run the services" -ForegroundColor Yellow
    $mavenAvailable = $false
}

# Check project structure
Write-Host "`n📁 Project Structure:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

$services = @("auth-service", "user-service", "gateway-service")
foreach ($service in $services) {
    if (Test-Path $service) {
        $javaFiles = (Get-ChildItem "$service/src" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
        Write-Host "✅ $service - $javaFiles Java files" -ForegroundColor Green
    } else {
        Write-Host "❌ $service - Missing" -ForegroundColor Red
    }
}

# Check parent POM
if (Test-Path "pom.xml") {
    Write-Host "✅ Parent POM - Present" -ForegroundColor Green
} else {
    Write-Host "❌ Parent POM - Missing" -ForegroundColor Red
}

Write-Host "`n🔧 Next Steps:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan

if (-not $mavenAvailable) {
    Write-Host "1. Install Apache Maven:" -ForegroundColor White
    Write-Host "   • Download from: https://maven.apache.org/download.cgi" -ForegroundColor Gray
    Write-Host "   • Add Maven bin directory to your PATH environment variable" -ForegroundColor Gray
    Write-Host "   • Restart your terminal/PowerShell" -ForegroundColor Gray
    Write-Host ""
} 

Write-Host "2. Database Setup (PostgreSQL):" -ForegroundColor White
Write-Host "   • Install PostgreSQL from: https://www.postgresql.org/download/" -ForegroundColor Gray
Write-Host "   • Create databases: springmon_auth, springmon_user" -ForegroundColor Gray
Write-Host "   • Update application.properties with your DB credentials" -ForegroundColor Gray

Write-Host "`n3. Build and Run Services:" -ForegroundColor White
if ($mavenAvailable) {
    Write-Host "   • mvn clean install (in root directory)" -ForegroundColor Gray
    Write-Host "   • cd auth-service; mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "   • cd user-service; mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "   • cd gateway-service; mvn spring-boot:run" -ForegroundColor Gray
} else {
    Write-Host "   • First install Maven, then run these commands:" -ForegroundColor Gray
    Write-Host "   • mvn clean install" -ForegroundColor Gray
    Write-Host "   • mvn spring-boot:run (in each service directory)" -ForegroundColor Gray
}

Write-Host "`n4. Alternative - Docker Setup:" -ForegroundColor White
Write-Host "   • Install Docker Desktop" -ForegroundColor Gray
Write-Host "   • Run: docker-compose up --build" -ForegroundColor Gray

Write-Host "`n📖 Documentation:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "• README.md - Complete project documentation" -ForegroundColor White
Write-Host "• API endpoints, architecture, and setup instructions" -ForegroundColor Gray

Write-Host "`n🎯 Service Ports:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "• Gateway Service: http://localhost:8080" -ForegroundColor White
Write-Host "• User Service: http://localhost:8081" -ForegroundColor White  
Write-Host "• Auth Service: http://localhost:8082" -ForegroundColor White

Write-Host "`n🎉 Project is ready for development!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Cyan
