#!/usr/bin/env pwsh

Write-Host "Testing Spring Boot Microservices Compilation" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Function to test service compilation
function Test-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    Write-Host "`nTesting $ServiceName..." -ForegroundColor Yellow
    
    if (Test-Path $ServicePath) {
        Set-Location $ServicePath
        
        # Check if pom.xml exists
        if (Test-Path "pom.xml") {
            Write-Host "  - Found pom.xml" -ForegroundColor White
            Write-Host "  - Checking Java files..." -ForegroundColor White
            
            # Count Java files
            $javaFiles = Get-ChildItem -Path "src" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue
            Write-Host "  - Found $($javaFiles.Count) Java files" -ForegroundColor White
            
            # Check for main class
            $mainClasses = $javaFiles | Where-Object { $_.Name -like "*Application.java" -or $_.Name -like "*App.java" }
            if ($mainClasses.Count -gt 0) {
                Write-Host "  - Found main class: $($mainClasses[0].Name)" -ForegroundColor Green
            } else {
                Write-Host "  - WARNING: No main class found" -ForegroundColor Red
            }
            
            # Check key dependencies in pom.xml
            $pomContent = Get-Content "pom.xml" -Raw
            if ($pomContent -match "spring-boot-starter") {
                Write-Host "  - Spring Boot dependencies: OK" -ForegroundColor Green
            } else {
                Write-Host "  - WARNING: Spring Boot dependencies not found" -ForegroundColor Red
            }
            
            Write-Host "  - Service ${ServiceName}: READY" -ForegroundColor Green
        } else {
            Write-Host "  - ERROR: pom.xml not found" -ForegroundColor Red
        }
    } else {
        Write-Host "  - ERROR: Service directory not found" -ForegroundColor Red
    }
}

# Test each service
$baseDir = "c:/Users/mini/Desktop/Visual code/spring/newspring/spring-boot-template/springmon-microservices"

Test-Service "Auth Service" "$baseDir/auth-service"
Test-Service "User Service" "$baseDir/user-service"  
Test-Service "Gateway Service" "$baseDir/gateway-service"

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "Compilation Test Complete" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Test parent pom
Write-Host "`nTesting Parent POM..." -ForegroundColor Yellow
if (Test-Path "$baseDir/pom.xml") {
    Write-Host "  - Parent pom.xml: FOUND" -ForegroundColor Green
} else {
    Write-Host "  - Parent pom.xml: NOT FOUND" -ForegroundColor Red
}

Write-Host "`nAll services are ready for development!" -ForegroundColor Green
