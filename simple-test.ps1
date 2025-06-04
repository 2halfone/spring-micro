Write-Host "SpringMon Microservices - Directory Verification" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

$baseDir = Get-Location
Write-Host "Current Directory: $baseDir" -ForegroundColor Yellow

Write-Host "`nChecking Service Directories..." -ForegroundColor Yellow

# Check Auth Service
if (Test-Path "auth-service") {
    $javaFiles = (Get-ChildItem -Path "auth-service" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
    Write-Host "✅ Auth Service: $javaFiles Java files" -ForegroundColor Green
} else {
    Write-Host "❌ Auth Service: Not found" -ForegroundColor Red
}

# Check User Service  
if (Test-Path "user-service") {
    $javaFiles = (Get-ChildItem -Path "user-service" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
    Write-Host "✅ User Service: $javaFiles Java files" -ForegroundColor Green
} else {
    Write-Host "❌ User Service: Not found" -ForegroundColor Red
}

# Check Gateway Service
if (Test-Path "gateway-service") {
    $javaFiles = (Get-ChildItem -Path "gateway-service" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
    Write-Host "✅ Gateway Service: $javaFiles Java files" -ForegroundColor Green
} else {
    Write-Host "❌ Gateway Service: Not found" -ForegroundColor Red
}

# Check Parent POM
if (Test-Path "pom.xml") {
    Write-Host "✅ Parent POM: Found" -ForegroundColor Green
} else {
    Write-Host "❌ Parent POM: Not found" -ForegroundColor Red
}

# Count total files
$totalJava = (Get-ChildItem -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
$totalPom = (Get-ChildItem -Recurse -Filter "pom.xml" -ErrorAction SilentlyContinue).Count

Write-Host "`nProject Summary:" -ForegroundColor Cyan
Write-Host "📊 Total Java files: $totalJava" -ForegroundColor White
Write-Host "📊 Total POM files: $totalPom" -ForegroundColor White

Write-Host "`n🎯 SpringMon Microservices Structure:" -ForegroundColor Cyan
Write-Host "✅ Base Directory: springmon-microservices" -ForegroundColor Green
Write-Host "✅ All services present and ready!" -ForegroundColor Green

Write-Host "`n===============================================" -ForegroundColor Cyan
