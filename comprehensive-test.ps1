# SpringMon Microservices - Comprehensive Testing Script
# =====================================================

Write-Host "🧪 SpringMon Microservices - Comprehensive Testing" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# Check if we're in the correct directory
$currentDir = Get-Location
if ($currentDir.Path -notlike "*springmon-microservices") {
    Write-Host "❌ ERROR: Please run this script from the springmon-microservices directory!" -ForegroundColor Red
    Write-Host "Current directory: $currentDir" -ForegroundColor Yellow
    Write-Host "Expected: *\springmon-microservices" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Correct directory: $currentDir" -ForegroundColor Green

# TEST 1: Prerequisites Check
Write-Host "`n🔍 TEST 1: Prerequisites Check..." -ForegroundColor Yellow

# Check Java
try {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    if ($javaVersion -match '"([0-9]+)"') {
        $javaMajor = [int]$matches[1]
        if ($javaMajor -ge 17) {
            Write-Host "✅ Java $javaMajor detected" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Java $javaMajor detected (Java 17+ recommended)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Java not found! Please install Java 17+" -ForegroundColor Red
}

# Check Maven
try {
    $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven" | ForEach-Object { $_.ToString() }
    if ($mavenVersion) {
        Write-Host "✅ Maven detected" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Maven not found! Please install Maven 3.6+" -ForegroundColor Red
}

# Check Docker (optional)
try {
    $dockerVersion = docker --version 2>&1
    if ($dockerVersion) {
        Write-Host "✅ Docker detected" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Docker not found (optional for development)" -ForegroundColor Yellow
}

# TEST 2: Project Structure Verification
Write-Host "`n📋 TEST 2: Project Structure Verification..." -ForegroundColor Yellow

$services = @("auth-service", "user-service", "gateway-service")
$allServicesReady = $true

foreach ($service in $services) {
    if (Test-Path $service) {
        $javaFiles = (Get-ChildItem -Path "$service\src" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue).Count
        $pomExists = Test-Path "$service\pom.xml"
        
        if ($pomExists -and $javaFiles -gt 0) {
            Write-Host "✅ $service`: $javaFiles Java files, pom.xml present" -ForegroundColor Green
        } else {
            Write-Host "❌ $service`: Missing files or pom.xml" -ForegroundColor Red
            $allServicesReady = $false
        }
    } else {
        Write-Host "❌ $service`: Directory not found" -ForegroundColor Red
        $allServicesReady = $false
    }
}

# TEST 3: Compilation Test
Write-Host "`n🔨 TEST 3: Compilation Test..." -ForegroundColor Yellow
$compilationSuccess = $true

foreach ($service in $services) {
    Write-Host "Compiling $service..." -ForegroundColor Gray
    Set-Location $service
    
    try {
        $result = mvn clean compile -q 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $service`: Compilation successful" -ForegroundColor Green
        } else {
            Write-Host "❌ $service`: Compilation failed" -ForegroundColor Red
            Write-Host "Error details: $result" -ForegroundColor Gray
            $compilationSuccess = $false
        }
    } catch {
        Write-Host "❌ $service`: Compilation error - $_" -ForegroundColor Red
        $compilationSuccess = $false
    }
    
    Set-Location ..
}

# TEST 4: Configuration Files Check
Write-Host "`n⚙️  TEST 4: Configuration Files Check..." -ForegroundColor Yellow

$configFiles = @(
    "auth-service\src\main\resources\application.properties",
    "user-service\src\main\resources\application.properties", 
    "gateway-service\src\main\resources\application.properties",
    "docker-compose.yml",
    "pom.xml"
)

$configComplete = $true
foreach ($config in $configFiles) {
    if (Test-Path $config) {
        Write-Host "✅ Configuration file: $config" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing configuration: $config" -ForegroundColor Red
        $configComplete = $false
    }
}

# TEST 5: Key Classes Verification
Write-Host "`n🏗️  TEST 5: Key Classes Verification..." -ForegroundColor Yellow

$keyClasses = @{
    "auth-service" = @("AuthServiceApplication.java", "AuthController.java", "JwtTokenProvider.java", "SecurityConfig.java")
    "user-service" = @("UserServiceApplication.java", "UserController.java", "UserService.java")
    "gateway-service" = @("GatewayServiceApplication.java", "JwtValidationService.java", "SecurityConfig.java")
}

$classesComplete = $true
foreach ($service in $keyClasses.Keys) {
    foreach ($class in $keyClasses[$service]) {
        $classPath = Get-ChildItem -Path "$service\src" -Recurse -Filter $class -ErrorAction SilentlyContinue
        if ($classPath) {
            Write-Host "✅ $service`: $class found" -ForegroundColor Green
        } else {
            Write-Host "❌ $service`: $class missing" -ForegroundColor Red
            $classesComplete = $false
        }
    }
}

# TEST 6: Dependencies Check
Write-Host "`n📦 TEST 6: Dependencies Check..." -ForegroundColor Yellow

$dependencyCheck = $true
foreach ($service in $services) {
    $pomPath = "$service\pom.xml"
    if (Test-Path $pomPath) {
        $pomContent = Get-Content $pomPath -Raw
        
        # Check for Spring Boot
        if ($pomContent -match "spring-boot-starter") {
            Write-Host "✅ $service`: Spring Boot dependencies found" -ForegroundColor Green
        } else {
            Write-Host "❌ $service`: Spring Boot dependencies missing" -ForegroundColor Red
            $dependencyCheck = $false
        }
        
        # Check for specific dependencies
        if ($service -eq "auth-service" -and $pomContent -match "jjwt") {
            Write-Host "✅ $service`: JWT dependencies found" -ForegroundColor Green
        } elseif ($service -eq "auth-service") {
            Write-Host "❌ $service`: JWT dependencies missing" -ForegroundColor Red
            $dependencyCheck = $false
        }
    }
}

# TEST 7: Port Configuration Check
Write-Host "`n🔌 TEST 7: Port Configuration Check..." -ForegroundColor Yellow

$portConfig = @{
    "auth-service" = "8082"
    "user-service" = "8081"
    "gateway-service" = "8080"
}

$portsConfigured = $true
foreach ($service in $portConfig.Keys) {
    $appPropPath = "$service\src\main\resources\application.properties"
    if (Test-Path $appPropPath) {
        $appPropContent = Get-Content $appPropPath -Raw
        $expectedPort = $portConfig[$service]
        
        if ($appPropContent -match "server\.port\s*=\s*$expectedPort") {
            Write-Host "✅ $service`: Port $expectedPort configured" -ForegroundColor Green
        } else {
            Write-Host "❌ $service`: Port $expectedPort not configured" -ForegroundColor Red
            $portsConfigured = $false
        }
    }
}

# Summary Report
Write-Host "`n📊 TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

$overallSuccess = $allServicesReady -and $compilationSuccess -and $configComplete -and $classesComplete -and $dependencyCheck -and $portsConfigured

Write-Host "`nTest Results:" -ForegroundColor White
Write-Host "• Project Structure: $(if ($allServicesReady) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($allServicesReady) { 'Green' } else { 'Red' })
Write-Host "• Compilation: $(if ($compilationSuccess) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($compilationSuccess) { 'Green' } else { 'Red' })
Write-Host "• Configuration: $(if ($configComplete) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($configComplete) { 'Green' } else { 'Red' })
Write-Host "• Key Classes: $(if ($classesComplete) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($classesComplete) { 'Green' } else { 'Red' })
Write-Host "• Dependencies: $(if ($dependencyCheck) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($dependencyCheck) { 'Green' } else { 'Red' })
Write-Host "• Port Config: $(if ($portsConfigured) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($portsConfigured) { 'Green' } else { 'Red' })

Write-Host "`n🎯 OVERALL RESULT:" -ForegroundColor Cyan

if ($overallSuccess) {
    Write-Host "🎉 ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "✅ SpringMon Microservices are ready for deployment" -ForegroundColor Green
    
    Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Setup PostgreSQL database (if not already done)" -ForegroundColor White
    Write-Host "2. Start services individually:" -ForegroundColor White
    Write-Host "   • cd auth-service && mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "   • cd user-service && mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "   • cd gateway-service && mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "3. Or use Docker Compose: docker-compose up -d" -ForegroundColor White
    Write-Host "4. Test APIs at http://localhost:8080" -ForegroundColor White
    
} else {
    Write-Host "❌ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "Please review the failed tests above and fix the issues." -ForegroundColor Yellow
    Write-Host "Check the detailed error messages for troubleshooting guidance." -ForegroundColor Yellow
}

Write-Host "`n===================================================" -ForegroundColor Cyan
Write-Host "SpringMon Microservices Testing Complete" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
