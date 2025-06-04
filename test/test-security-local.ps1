# TEST LOCALE SPRING SECURITY - PUNTO 1
# =====================================

Write-Host "🧪 TESTING SPRING SECURITY IMPLEMENTATION - PUNTO 1" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

$ErrorActionPreference = "Continue"
$testResults = @()

# Function per logging risultati
function Add-TestResult {
    param($Category, $TestName, $Result, $Details)
    $global:testResults += [PSCustomObject]@{
        Category = $Category
        Test = $TestName
        Result = $Result
        Details = $Details
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
}

Write-Host "`n🔍 TEST 1: VERIFICA FILE DI CONFIGURAZIONE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Lista file di sicurezza richiesti
$securityFiles = @(
    @{Path="gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java"; Service="Gateway"; Type="SecurityConfig"},
    @{Path="gateway-service\src\main\java\com\springmon\gateway\config\JwtAuthenticationFilter.java"; Service="Gateway"; Type="JwtFilter"},
    @{Path="gateway-service\src\main\java\com\springmon\gateway\config\JwtAuthenticationEntryPoint.java"; Service="Gateway"; Type="EntryPoint"},
    @{Path="user-service\src\main\java\com\springmon\user\config\SecurityConfig.java"; Service="User"; Type="SecurityConfig"},
    @{Path="user-service\src\main\java\com\springmon\user\config\JwtAuthenticationFilter.java"; Service="User"; Type="JwtFilter"},
    @{Path="user-service\src\main\java\com\springmon\user\config\JwtAuthenticationEntryPoint.java"; Service="User"; Type="EntryPoint"},
    @{Path="user-service\pom.xml"; Service="User"; Type="Dependencies"},
    @{Path="user-service\src\main\resources\application.properties"; Service="User"; Type="Properties"}
)

foreach ($file in $securityFiles) {
    if (Test-Path $file.Path) {
        Add-TestResult "Files" "$($file.Service) $($file.Type)" "✅ PASS" "File exists: $($file.Path)"
        Write-Host "✅ $($file.Service) $($file.Type): $($file.Path)" -ForegroundColor Green
    } else {
        Add-TestResult "Files" "$($file.Service) $($file.Type)" "❌ FAIL" "File missing: $($file.Path)"
        Write-Host "❌ $($file.Service) $($file.Type): $($file.Path) MISSING" -ForegroundColor Red
    }
}

Write-Host "`n🔧 TEST 2: VERIFICA CONTENUTO CONFIGURAZIONI" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Test contenuto SecurityConfig Gateway
if (Test-Path "gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java") {
    $gatewaySecConfig = Get-Content "gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java" -Raw
    
    if ($gatewaySecConfig -match "@EnableWebSecurity" -and $gatewaySecConfig -match "SecurityFilterChain") {
        Add-TestResult "Content" "Gateway SecurityConfig" "✅ PASS" "Contains required annotations"
        Write-Host "✅ Gateway SecurityConfig: Contains @EnableWebSecurity and SecurityFilterChain" -ForegroundColor Green
    } else {
        Add-TestResult "Content" "Gateway SecurityConfig" "❌ FAIL" "Missing required annotations"
        Write-Host "❌ Gateway SecurityConfig: Missing required annotations" -ForegroundColor Red
    }
    
    if ($gatewaySecConfig -match "JwtAuthenticationFilter" -and $gatewaySecConfig -match "addFilterBefore") {
        Add-TestResult "Content" "Gateway JWT Filter Config" "✅ PASS" "JWT filter properly configured"
        Write-Host "✅ Gateway SecurityConfig: JWT filter properly configured" -ForegroundColor Green
    } else {
        Add-TestResult "Content" "Gateway JWT Filter Config" "❌ FAIL" "JWT filter not configured"
        Write-Host "❌ Gateway SecurityConfig: JWT filter not properly configured" -ForegroundColor Red
    }
}

# Test contenuto SecurityConfig User Service
if (Test-Path "user-service\src\main\java\com\springmon\user\config\SecurityConfig.java") {
    $userSecConfig = Get-Content "user-service\src\main\java\com\springmon\user\config\SecurityConfig.java" -Raw
    
    if ($userSecConfig -match "@EnableWebSecurity" -and $userSecConfig -match "SecurityFilterChain") {
        Add-TestResult "Content" "User SecurityConfig" "✅ PASS" "Contains required annotations"
        Write-Host "✅ User SecurityConfig: Contains @EnableWebSecurity and SecurityFilterChain" -ForegroundColor Green
    } else {
        Add-TestResult "Content" "User SecurityConfig" "❌ FAIL" "Missing required annotations"
        Write-Host "❌ User SecurityConfig: Missing required annotations" -ForegroundColor Red
    }
    
    if ($userSecConfig -match "permitAll.*health" -or $userSecConfig -match "health.*permitAll") {
        Add-TestResult "Content" "User Health Endpoint" "✅ PASS" "Health endpoint configured as public"
        Write-Host "✅ User SecurityConfig: Health endpoint configured as public" -ForegroundColor Green
    } else {
        Add-TestResult "Content" "User Health Endpoint" "⚠️ WARN" "Health endpoint configuration unclear"
        Write-Host "⚠️ User SecurityConfig: Health endpoint configuration unclear" -ForegroundColor Yellow
    }
}

# Test dipendenze User Service
if (Test-Path "user-service\pom.xml") {
    $userPom = Get-Content "user-service\pom.xml" -Raw
    
    if ($userPom -match "spring-boot-starter-security") {
        Add-TestResult "Dependencies" "Spring Security" "✅ PASS" "Spring Security dependency found"
        Write-Host "✅ User Service: Spring Security dependency found" -ForegroundColor Green
    } else {
        Add-TestResult "Dependencies" "Spring Security" "❌ FAIL" "Spring Security dependency missing"
        Write-Host "❌ User Service: Spring Security dependency missing" -ForegroundColor Red
    }
    
    if ($userPom -match "jjwt-api" -and $userPom -match "jjwt-impl") {
        Add-TestResult "Dependencies" "JWT Libraries" "✅ PASS" "JWT dependencies found"
        Write-Host "✅ User Service: JWT dependencies found" -ForegroundColor Green
    } else {
        Add-TestResult "Dependencies" "JWT Libraries" "❌ FAIL" "JWT dependencies missing"
        Write-Host "❌ User Service: JWT dependencies missing" -ForegroundColor Red
    }
}

# Test JWT secret configuration
$jwtSecretFound = $false
$configFiles = @("auth-service\src\main\resources\application.properties", 
                 "gateway-service\src\main\resources\application.properties",
                 "user-service\src\main\resources\application.properties")

foreach ($configFile in $configFiles) {
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        if ($content -match "jwt\.secret") {
            $jwtSecretFound = $true
            $serviceName = Split-Path (Split-Path (Split-Path $configFile -Parent) -Parent) -Leaf
            Add-TestResult "Configuration" "$serviceName JWT Secret" "✅ PASS" "JWT secret configured"
            Write-Host "✅ $serviceName: JWT secret configured" -ForegroundColor Green
        }
    }
}

if (-not $jwtSecretFound) {
    Add-TestResult "Configuration" "JWT Secret" "❌ FAIL" "No JWT secret found in any service"
    Write-Host "❌ JWT Secret: Not found in any service configuration" -ForegroundColor Red
}

Write-Host "`n📋 TEST 3: COMPILAZIONE E SYNTAX CHECK" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Controlla se Maven è disponibile
try {
    $mvnVersion = mvn -version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven disponibile per test di compilazione" -ForegroundColor Green
        
        # Test compilazione Gateway Service
        Write-Host "`nTesting Gateway Service compilation..." -ForegroundColor Yellow
        Push-Location "gateway-service"
        try {
            $compileOutput = mvn clean compile -q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-TestResult "Compilation" "Gateway Service" "✅ PASS" "Compiled successfully"
                Write-Host "✅ Gateway Service: Compilation successful" -ForegroundColor Green
            } else {
                Add-TestResult "Compilation" "Gateway Service" "❌ FAIL" "Compilation failed"
                Write-Host "❌ Gateway Service: Compilation failed" -ForegroundColor Red
                Write-Host "Error details: $compileOutput" -ForegroundColor Red
            }
        } catch {
            Add-TestResult "Compilation" "Gateway Service" "❌ FAIL" "Exception during compilation"
            Write-Host "❌ Gateway Service: Exception during compilation" -ForegroundColor Red
        }
        Pop-Location
        
        # Test compilazione User Service
        Write-Host "`nTesting User Service compilation..." -ForegroundColor Yellow
        Push-Location "user-service"
        try {
            $compileOutput = mvn clean compile -q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-TestResult "Compilation" "User Service" "✅ PASS" "Compiled successfully"
                Write-Host "✅ User Service: Compilation successful" -ForegroundColor Green
            } else {
                Add-TestResult "Compilation" "User Service" "❌ FAIL" "Compilation failed"
                Write-Host "❌ User Service: Compilation failed" -ForegroundColor Red
                Write-Host "Error details: $compileOutput" -ForegroundColor Red
            }
        } catch {
            Add-TestResult "Compilation" "User Service" "❌ FAIL" "Exception during compilation"
            Write-Host "❌ User Service: Exception during compilation" -ForegroundColor Red
        }
        Pop-Location
        
        # Test compilazione Auth Service
        Write-Host "`nTesting Auth Service compilation..." -ForegroundColor Yellow
        Push-Location "auth-service"
        try {
            $compileOutput = mvn clean compile -q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-TestResult "Compilation" "Auth Service" "✅ PASS" "Compiled successfully"
                Write-Host "✅ Auth Service: Compilation successful" -ForegroundColor Green
            } else {
                Add-TestResult "Compilation" "Auth Service" "❌ FAIL" "Compilation failed"
                Write-Host "❌ Auth Service: Compilation failed" -ForegroundColor Red
                Write-Host "Error details: $compileOutput" -ForegroundColor Red
            }
        } catch {
            Add-TestResult "Compilation" "Auth Service" "❌ FAIL" "Exception during compilation"
            Write-Host "❌ Auth Service: Exception during compilation" -ForegroundColor Red
        }
        Pop-Location
        
    } else {
        Add-TestResult "Tools" "Maven" "⚠️ SKIP" "Maven not available for compilation tests"
        Write-Host "⚠️ Maven non disponibile - Skip test di compilazione" -ForegroundColor Yellow
    }
} catch {
    Add-TestResult "Tools" "Maven" "⚠️ SKIP" "Maven not found"
    Write-Host "⚠️ Maven non trovato - Skip test di compilazione" -ForegroundColor Yellow
}

Write-Host "`n🔍 TEST 4: ANALISI STRUTTURA CLASSI" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Conta le classi di sicurezza implementate
$securityClasses = @(
    "gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java",
    "gateway-service\src\main\java\com\springmon\gateway\config\JwtAuthenticationFilter.java",
    "gateway-service\src\main\java\com\springmon\gateway\config\JwtAuthenticationEntryPoint.java",
    "user-service\src\main\java\com\springmon\user\config\SecurityConfig.java",
    "user-service\src\main\java\com\springmon\user\config\JwtAuthenticationFilter.java",
    "user-service\src\main\java\com\springmon\user\config\JwtAuthenticationEntryPoint.java"
)

$implementedClasses = 0
foreach ($class in $securityClasses) {
    if (Test-Path $class) {
        $implementedClasses++
    }
}

$totalExpectedClasses = $securityClasses.Count
Add-TestResult "Structure" "Security Classes" "ℹ️ INFO" "$implementedClasses/$totalExpectedClasses classes implemented"
Write-Host "📊 Security Classes: $implementedClasses/$totalExpectedClasses implemented" -ForegroundColor Cyan

# Verifica annotazioni Spring Security
$annotationChecks = @()
foreach ($class in $securityClasses) {
    if (Test-Path $class) {
        $content = Get-Content $class -Raw
        $fileName = Split-Path $class -Leaf
        
        if ($fileName -eq "SecurityConfig.java") {
            if ($content -match "@Configuration" -and $content -match "@EnableWebSecurity") {
                $annotationChecks += "✅ $fileName: Required annotations present"
            } else {
                $annotationChecks += "❌ $fileName: Missing required annotations"
            }
        }
        
        if ($fileName -eq "JwtAuthenticationFilter.java") {
            if ($content -match "@Component" -or $content -match "OncePerRequestFilter") {
                $annotationChecks += "✅ $fileName: Proper filter implementation"
            } else {
                $annotationChecks += "❌ $fileName: Improper filter implementation"
            }
        }
        
        if ($fileName -eq "JwtAuthenticationEntryPoint.java") {
            if ($content -match "@Component" -and $content -match "AuthenticationEntryPoint") {
                $annotationChecks += "✅ $fileName: Proper entry point implementation"
            } else {
                $annotationChecks += "❌ $fileName: Improper entry point implementation"
            }
        }
    }
}

foreach ($check in $annotationChecks) {
    Write-Host $check -ForegroundColor $(if ($check.StartsWith("✅")) { "Green" } else { "Red" })
}

Write-Host "`n📊 RIEPILOGO RISULTATI TEST" -ForegroundColor Magenta
Write-Host "============================" -ForegroundColor Magenta

# Raggruppa risultati per categoria
$groupedResults = $testResults | Group-Object Category

foreach ($group in $groupedResults) {
    Write-Host "`n📋 $($group.Name):" -ForegroundColor Cyan
    $group.Group | Format-Table Test, Result, Details -AutoSize
}

# Calcola statistiche finali
$passedTests = ($testResults | Where-Object { $_.Result -eq "✅ PASS" }).Count
$failedTests = ($testResults | Where-Object { $_.Result -eq "❌ FAIL" }).Count
$skippedTests = ($testResults | Where-Object { $_.Result -eq "⚠️ SKIP" -or $_.Result -eq "⚠️ WARN" }).Count
$infoTests = ($testResults | Where-Object { $_.Result -eq "ℹ️ INFO" }).Count
$totalTests = $testResults.Count

Write-Host "`n🎯 STATISTICHE FINALI:" -ForegroundColor Magenta
Write-Host "✅ Passed: $passedTests" -ForegroundColor Green
Write-Host "❌ Failed: $failedTests" -ForegroundColor Red
Write-Host "⚠️ Skipped/Warning: $skippedTests" -ForegroundColor Yellow
Write-Host "ℹ️ Info: $infoTests" -ForegroundColor Cyan
Write-Host "📊 Total: $totalTests" -ForegroundColor White

# Valutazione finale
$successRate = [math]::Round(($passedTests / ($passedTests + $failedTests)) * 100, 2)

Write-Host "`n🎉 VALUTAZIONE IMPLEMENTAZIONE PUNTO 1:" -ForegroundColor Magenta
if ($failedTests -eq 0) {
    Write-Host "🟢 EXCELLENT: Tutte le implementazioni Spring Security sono corrette!" -ForegroundColor Green
    Write-Host "✅ Punto 1 - CONFIGURAZIONE SPRING SECURITY: COMPLETATO CON SUCCESSO" -ForegroundColor Green
} elseif ($successRate -ge 80) {
    Write-Host "🟡 GOOD: Implementazione sostanzialmente corretta con alcuni warning" -ForegroundColor Yellow
    Write-Host "⚠️ Punto 1 - CONFIGURAZIONE SPRING SECURITY: COMPLETATO CON MINOR ISSUES" -ForegroundColor Yellow
} elseif ($successRate -ge 60) {
    Write-Host "🟠 FAIR: Implementazione parziale, alcuni componenti mancanti" -ForegroundColor Yellow
    Write-Host "⚠️ Punto 1 - CONFIGURAZIONE SPRING SECURITY: PARZIALMENTE COMPLETATO" -ForegroundColor Yellow
} else {
    Write-Host "🔴 POOR: Implementazione incompleta, richiede interventi" -ForegroundColor Red
    Write-Host "❌ Punto 1 - CONFIGURAZIONE SPRING SECURITY: RICHIEDE CORREZIONI" -ForegroundColor Red
}

Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor Cyan

Write-Host "`n🚀 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Review failed tests if any" -ForegroundColor White
Write-Host "2. Proceed to Priority 2: JWT SECURITY ENHANCEMENT" -ForegroundColor White
Write-Host "3. Run integration tests when services are deployed" -ForegroundColor White

Write-Host "`n🧪 Test completato: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
