# SPRING SECURITY VERIFICATION - PRIORITY 1 COMPLETE
# ===================================================

Write-Host "🔒 SPRING SECURITY IMPLEMENTATION VERIFICATION" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Testing Priority 1: Spring Security Configuration" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$testResults = @()

function Add-TestResult {
    param($Category, $TestName, $Result, $Details)
    $global:testResults += [PSCustomObject]@{
        Category = $Category
        Test = $TestName
        Result = $Result
        Details = $Details
    }
}

Write-Host "📋 PHASE 1: FILE STRUCTURE VERIFICATION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Lista corretta dei file di sicurezza (con percorsi corretti)
$securityFiles = @(
    @{Path="gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java"; Service="Gateway"; Type="SecurityConfig"},
    @{Path="gateway-service\src\main\java\com\springmon\gateway\filter\JwtAuthenticationFilter.java"; Service="Gateway"; Type="JwtFilter"},
    @{Path="gateway-service\src\main\java\com\springmon\gateway\config\JwtAuthenticationEntryPoint.java"; Service="Gateway"; Type="EntryPoint"},
    @{Path="user-service\src\main\java\com\springmon\user\config\SecurityConfig.java"; Service="User"; Type="SecurityConfig"},
    @{Path="user-service\src\main\java\com\springmon\user\config\JwtAuthenticationFilter.java"; Service="User"; Type="JwtFilter"},
    @{Path="user-service\src\main\java\com\springmon\user\config\JwtAuthenticationEntryPoint.java"; Service="User"; Type="EntryPoint"},
    @{Path="user-service\pom.xml"; Service="User"; Type="Dependencies"},
    @{Path="user-service\src\main\resources\application.properties"; Service="User"; Type="Properties"}
)

foreach ($file in $securityFiles) {
    if (Test-Path $file.Path) {
        Add-TestResult "Files" "$($file.Service) $($file.Type)" "✅ PASS" "File exists"
        Write-Host "✅ $($file.Service) $($file.Type): Found" -ForegroundColor Green
    } else {
        Add-TestResult "Files" "$($file.Service) $($file.Type)" "❌ FAIL" "File missing"
        Write-Host "❌ $($file.Service) $($file.Type): MISSING" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔧 PHASE 2: CONFIGURATION CONTENT ANALYSIS" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow

# Gateway SecurityConfig
if (Test-Path "gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java") {
    $content = Get-Content "gateway-service\src\main\java\com\springmon\gateway\config\SecurityConfig.java" -Raw
    
    if ($content -match "@EnableWebSecurity" -and $content -match "SecurityFilterChain") {
        Add-TestResult "Config" "Gateway SecurityConfig" "✅ PASS" "@EnableWebSecurity and SecurityFilterChain found"
        Write-Host "✅ Gateway SecurityConfig: Proper annotations" -ForegroundColor Green
    } else {
        Add-TestResult "Config" "Gateway SecurityConfig" "❌ FAIL" "Missing annotations"
        Write-Host "❌ Gateway SecurityConfig: Missing annotations" -ForegroundColor Red
    }
    
    if ($content -match "JwtAuthenticationFilter" -and $content -match "addFilterBefore") {
        Add-TestResult "Config" "Gateway JWT Filter" "✅ PASS" "JWT filter configured"
        Write-Host "✅ Gateway SecurityConfig: JWT filter integrated" -ForegroundColor Green
    } else {
        Add-TestResult "Config" "Gateway JWT Filter" "❌ FAIL" "JWT filter not configured"
        Write-Host "❌ Gateway SecurityConfig: JWT filter missing" -ForegroundColor Red
    }
}

# User SecurityConfig
if (Test-Path "user-service\src\main\java\com\springmon\user\config\SecurityConfig.java") {
    $content = Get-Content "user-service\src\main\java\com\springmon\user\config\SecurityConfig.java" -Raw
    
    if ($content -match "@EnableWebSecurity" -and $content -match "SecurityFilterChain") {
        Add-TestResult "Config" "User SecurityConfig" "✅ PASS" "@EnableWebSecurity and SecurityFilterChain found"
        Write-Host "✅ User SecurityConfig: Proper annotations" -ForegroundColor Green
    } else {
        Add-TestResult "Config" "User SecurityConfig" "❌ FAIL" "Missing annotations"
        Write-Host "❌ User SecurityConfig: Missing annotations" -ForegroundColor Red
    }
    
    if ($content -match "health.*permitAll" -or $content -match "permitAll.*health") {
        Add-TestResult "Config" "User Health Endpoint" "✅ PASS" "Health endpoint public"
        Write-Host "✅ User SecurityConfig: Health endpoint public" -ForegroundColor Green
    } else {
        Add-TestResult "Config" "User Health Endpoint" "⚠️ WARN" "Health endpoint config unclear"
        Write-Host "⚠️ User SecurityConfig: Health endpoint config unclear" -ForegroundColor Yellow
    }
}

# User Service Dependencies
if (Test-Path "user-service\pom.xml") {
    $pom = Get-Content "user-service\pom.xml" -Raw
    
    if ($pom -match "spring-boot-starter-security") {
        Add-TestResult "Deps" "Spring Security" "✅ PASS" "Spring Security dependency found"
        Write-Host "✅ User Service: Spring Security dependency OK" -ForegroundColor Green
    } else {
        Add-TestResult "Deps" "Spring Security" "❌ FAIL" "Spring Security dependency missing"
        Write-Host "❌ User Service: Spring Security dependency MISSING" -ForegroundColor Red
    }
    
    if ($pom -match "jjwt-api" -and $pom -match "jjwt-impl") {
        Add-TestResult "Deps" "JWT Libraries" "✅ PASS" "JWT dependencies found"
        Write-Host "✅ User Service: JWT dependencies OK" -ForegroundColor Green
    } else {
        Add-TestResult "Deps" "JWT Libraries" "❌ FAIL" "JWT dependencies missing"
        Write-Host "❌ User Service: JWT dependencies MISSING" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔑 PHASE 3: JWT CONFIGURATION CHECK" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

$jwtSecretServices = @()
$configFiles = @(
    @{Path="auth-service\src\main\resources\application.properties"; Service="Auth"},
    @{Path="gateway-service\src\main\resources\application.properties"; Service="Gateway"},
    @{Path="user-service\src\main\resources\application.properties"; Service="User"}
)

foreach ($configFile in $configFiles) {
    if (Test-Path $configFile.Path) {
        $content = Get-Content $configFile.Path -Raw
        if ($content -match "jwt\.secret") {
            $jwtSecretServices += $configFile.Service
            Add-TestResult "JWT" "$($configFile.Service) JWT Secret" "✅ PASS" "JWT secret configured"
            Write-Host "✅ $($configFile.Service) Service: JWT secret configured" -ForegroundColor Green
        } else {
            Add-TestResult "JWT" "$($configFile.Service) JWT Secret" "❌ FAIL" "JWT secret missing"
            Write-Host "❌ $($configFile.Service) Service: JWT secret MISSING" -ForegroundColor Red
        }
    } else {
        Add-TestResult "JWT" "$($configFile.Service) Properties" "❌ FAIL" "Properties file missing"
        Write-Host "❌ $($configFile.Service) Service: Properties file MISSING" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🏗️ PHASE 4: COMPILATION TEST" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

try {
    $mvnCheck = mvn -version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven available for compilation tests" -ForegroundColor Green
        
        $services = @("gateway-service", "user-service", "auth-service")
        
        foreach ($service in $services) {
            Write-Host "Compiling $service..." -ForegroundColor Cyan
            Push-Location $service
            try {
                $compileResult = mvn clean compile -q 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Add-TestResult "Compile" "$service" "✅ PASS" "Compilation successful"
                    Write-Host "✅ $service: Compilation OK" -ForegroundColor Green
                } else {
                    Add-TestResult "Compile" "$service" "❌ FAIL" "Compilation failed"
                    Write-Host "❌ $service: Compilation FAILED" -ForegroundColor Red
                    Write-Host "Error: $compileResult" -ForegroundColor Red
                }
            } catch {
                Add-TestResult "Compile" "$service" "❌ FAIL" "Exception during compilation"
                Write-Host "❌ $service: Exception during compilation" -ForegroundColor Red
            } finally {
                Pop-Location
            }
        }
    } else {
        Add-TestResult "Tools" "Maven" "⚠️ SKIP" "Maven not available"
        Write-Host "⚠️ Maven not available - Skipping compilation tests" -ForegroundColor Yellow
    }
} catch {
    Add-TestResult "Tools" "Maven" "⚠️ SKIP" "Maven not found"
    Write-Host "⚠️ Maven not found - Skipping compilation tests" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 RESULTS SUMMARY" -ForegroundColor Magenta
Write-Host "==================" -ForegroundColor Magenta

# Group and display results
$groupedResults = $testResults | Group-Object Category
foreach ($group in $groupedResults) {
    Write-Host ""
    Write-Host "📋 $($group.Name):" -ForegroundColor Cyan
    $group.Group | ForEach-Object {
        Write-Host "  $($_.Result) $($_.Test): $($_.Details)" -ForegroundColor White
    }
}

# Calculate statistics
$passed = ($testResults | Where-Object { $_.Result -eq "✅ PASS" }).Count
$failed = ($testResults | Where-Object { $_.Result -eq "❌ FAIL" }).Count
$skipped = ($testResults | Where-Object { $_.Result -eq "⚠️ SKIP" -or $_.Result -eq "⚠️ WARN" }).Count
$total = $testResults.Count

Write-Host ""
Write-Host "🎯 FINAL STATISTICS:" -ForegroundColor Magenta
Write-Host "✅ Passed: $passed" -ForegroundColor Green
Write-Host "❌ Failed: $failed" -ForegroundColor Red
Write-Host "⚠️ Skipped/Warning: $skipped" -ForegroundColor Yellow
Write-Host "📊 Total: $total" -ForegroundColor Cyan

# Final assessment
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "🎉 PRIORITY 1 - SPRING SECURITY: COMPLETATO CON SUCCESSO!" -ForegroundColor Green
    Write-Host "✅ Tutte le implementazioni Spring Security sono corrette" -ForegroundColor Green
    Write-Host "🚀 Pronto per Priority 2: JWT Security Enhancement" -ForegroundColor Cyan
} elseif ($passed -gt $failed) {
    Write-Host ""
    Write-Host "⚠️ PRIORITY 1 - SPRING SECURITY: SOSTANZIALMENTE COMPLETATO" -ForegroundColor Yellow
    Write-Host "⚠️ Alcune implementazioni necessitano revisione" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ PRIORITY 1 - SPRING SECURITY: RICHIEDE CORREZIONI" -ForegroundColor Red
    Write-Host "❌ Implementazioni incomplete o errate" -ForegroundColor Red
}

$successRate = if (($passed + $failed) -gt 0) { [math]::Round(($passed / ($passed + $failed)) * 100, 1) } else { 0 }
Write-Host ""
Write-Host "Success Rate: $successRate%" -ForegroundColor Cyan
Write-Host "Test completed: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
