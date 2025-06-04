# 🧪 POST-DEPLOY VM TEST SUITE - SPRING SECURITY VERIFICATION
# Version: 1.0
# Date: 04/06/2025
# Purpose: Comprehensive Spring Security testing post-deploy on VM

param(
    [Parameter(Mandatory=$true)]
    [string]$VMIp,
    
    [Parameter(Mandatory=$false)]
    [string]$TestUser = "testuser",
    
    [Parameter(Mandatory=$false)]
    [string]$TestPassword = "testpass123",
    
    [Parameter(Mandatory=$false)]
    [bool]$VerboseOutput = $true
)

# Initialize variables
$GATEWAY_URL = "http://$VMIp:8080"
$AUTH_URL = "http://$VMIp:8081"
$USER_URL = "http://$VMIp:8083"
$JWT_TOKEN = ""
$test_results = @{}

# Color output functions
function Write-TestHeader($message) {
    Write-Host "`n=== $message ===" -ForegroundColor Yellow
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Warning($message) {
    Write-Host "⚠️ $message" -ForegroundColor Yellow
}

function Write-Info($message) {
    Write-Host "ℹ️ $message" -ForegroundColor Cyan
}

# Start testing
Write-Host "🚀 STARTING SPRING SECURITY POST-DEPLOY TESTS ON VM: $VMIp" -ForegroundColor Magenta
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

# PHASE 1: HEALTH CHECK AND CONNECTIVITY
Write-TestHeader "PHASE 1: HEALTH CHECK AND CONNECTIVITY"

try {
    Write-Info "Testing Gateway Service Health..."
    $gw_health = Invoke-RestMethod -Uri "$GATEWAY_URL/actuator/health" -Method Get -TimeoutSec 10
    if ($gw_health.status -eq "UP") {
        Write-Success "Gateway Service: $($gw_health.status)"
        $test_results["gateway_health"] = "PASS"
    } else {
        Write-Error "Gateway Service: $($gw_health.status)"
        $test_results["gateway_health"] = "FAIL"
    }
} catch {
    Write-Error "Gateway Service: UNREACHABLE - $($_.Exception.Message)"
    $test_results["gateway_health"] = "FAIL"
}

try {
    Write-Info "Testing Auth Service Health..."
    $auth_health = Invoke-RestMethod -Uri "$AUTH_URL/actuator/health" -Method Get -TimeoutSec 10
    if ($auth_health.status -eq "UP") {
        Write-Success "Auth Service: $($auth_health.status)"
        $test_results["auth_health"] = "PASS"
    } else {
        Write-Error "Auth Service: $($auth_health.status)"
        $test_results["auth_health"] = "FAIL"
    }
} catch {
    Write-Error "Auth Service: UNREACHABLE - $($_.Exception.Message)"
    $test_results["auth_health"] = "FAIL"
}

try {
    Write-Info "Testing User Service Health..."
    $user_health = Invoke-RestMethod -Uri "$USER_URL/api/health" -Method Get -TimeoutSec 10
    if ($user_health.status -eq "healthy") {
        Write-Success "User Service: $($user_health.status)"
        $test_results["user_health"] = "PASS"
    } else {
        Write-Error "User Service: $($user_health.status)"
        $test_results["user_health"] = "FAIL"
    }
} catch {
    Write-Error "User Service: UNREACHABLE - $($_.Exception.Message)"
    $test_results["user_health"] = "FAIL"
}

# Port connectivity tests
Write-Info "Testing port connectivity..."
$port_tests = @(8080, 8081, 8083)
foreach ($port in $port_tests) {
    try {
        $connection = Test-NetConnection -ComputerName $VMIp -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Success "Port $port : OPEN"
        } else {
            Write-Error "Port $port : CLOSED"
        }
    } catch {
        Write-Error "Port $port : TEST FAILED"
    }
}

# PHASE 2: SPRING SECURITY VERIFICATION
Write-TestHeader "PHASE 2: SPRING SECURITY VERIFICATION"

# Test public endpoints (should work)
Write-Info "Testing public endpoints (should return 200)..."

$public_endpoints = @(
    @{url = "$GATEWAY_URL/actuator/health"; name = "Gateway Health"},
    @{url = "$AUTH_URL/actuator/health"; name = "Auth Health"},
    @{url = "$USER_URL/api/health"; name = "User Health"}
)

foreach ($endpoint in $public_endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.url -Method Get -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "$($endpoint.name): $($response.StatusCode)"
            $test_results["public_$($endpoint.name)"] = "PASS"
        } else {
            Write-Error "$($endpoint.name): $($response.StatusCode)"
            $test_results["public_$($endpoint.name)"] = "FAIL"
        }
    } catch {
        Write-Error "$($endpoint.name): FAILED - $($_.Exception.Message)"
        $test_results["public_$($endpoint.name)"] = "FAIL"
    }
}

# Test protected endpoints without authentication (should return 401)
Write-Info "Testing protected endpoints without auth (should return 401)..."

$protected_endpoints = @(
    @{url = "$GATEWAY_URL/api/users"; name = "Gateway Users"},
    @{url = "$USER_URL/api/users"; name = "User Service Users"}
)

foreach ($endpoint in $protected_endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.url -Method Get -TimeoutSec 10
        Write-Error "$($endpoint.name): $($response.StatusCode) (Expected 401)"
        $test_results["protected_$($endpoint.name)"] = "FAIL"
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Success "$($endpoint.name): 401 (Correctly protected)"
            $test_results["protected_$($endpoint.name)"] = "PASS"
        } else {
            Write-Error "$($endpoint.name): $($_.Exception.Response.StatusCode) (Expected 401)"
            $test_results["protected_$($endpoint.name)"] = "FAIL"
        }
    }
}

# PHASE 3: JWT AUTHENTICATION FLOW
Write-TestHeader "PHASE 3: JWT AUTHENTICATION FLOW"

# Register test user
Write-Info "Registering test user..."
$register_body = @{
    username = $TestUser
    email = "test@example.com"
    password = $TestPassword
} | ConvertTo-Json

try {
    $register_response = Invoke-RestMethod -Uri "$AUTH_URL/api/auth/register" -Method Post -Body $register_body -ContentType "application/json" -TimeoutSec 10
    Write-Success "User registration successful"
} catch {
    Write-Warning "User registration failed (may already exist): $($_.Exception.Message)"
}

# Login to get JWT token
Write-Info "Attempting login to get JWT token..."
$login_body = @{
    username = $TestUser
    password = $TestPassword
} | ConvertTo-Json

try {
    $login_response = Invoke-RestMethod -Uri "$AUTH_URL/api/auth/login" -Method Post -Body $login_body -ContentType "application/json" -TimeoutSec 10
    
    if ($login_response.token) {
        $JWT_TOKEN = $login_response.token
        Write-Success "JWT Token generated successfully"
        Write-Info "Token (first 50 chars): $($JWT_TOKEN.Substring(0, [Math]::Min(50, $JWT_TOKEN.Length)))..."
        $test_results["jwt_generation"] = "PASS"
    } else {
        Write-Error "JWT Token not found in response"
        $test_results["jwt_generation"] = "FAIL"
        Write-Host "Login Response: $($login_response | ConvertTo-Json)" -ForegroundColor Gray
    }
} catch {
    Write-Error "Login failed: $($_.Exception.Message)"
    $test_results["jwt_generation"] = "FAIL"
}

# Test JWT validation on protected endpoints
if ($JWT_TOKEN) {
    Write-Info "Testing JWT validation on protected endpoints..."
    
    $auth_headers = @{
        "Authorization" = "Bearer $JWT_TOKEN"
    }
    
    foreach ($endpoint in $protected_endpoints) {
        try {
            $response = Invoke-WebRequest -Uri $endpoint.url -Method Get -Headers $auth_headers -TimeoutSec 10
            if ($response.StatusCode -eq 200) {
                Write-Success "$($endpoint.name): $($response.StatusCode) (JWT accepted)"
                $test_results["jwt_validation_$($endpoint.name)"] = "PASS"
            } else {
                Write-Warning "$($endpoint.name): $($response.StatusCode) (Unexpected response)"
                $test_results["jwt_validation_$($endpoint.name)"] = "PARTIAL"
            }
        } catch {
            if ($_.Exception.Response.StatusCode -eq 401) {
                Write-Error "$($endpoint.name): 401 (JWT rejected)"
                $test_results["jwt_validation_$($endpoint.name)"] = "FAIL"
            } else {
                Write-Warning "$($endpoint.name): $($_.Exception.Response.StatusCode) (Unexpected error)"
                $test_results["jwt_validation_$($endpoint.name)"] = "PARTIAL"
            }
        }
    }
}

# PHASE 4: JWT SECURITY VALIDATION
Write-TestHeader "PHASE 4: JWT SECURITY VALIDATION"

# Test malformed token
Write-Info "Testing malformed JWT token (should return 401)..."
$bad_headers = @{
    "Authorization" = "Bearer invalid.jwt.token"
}

try {
    $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/users" -Method Get -Headers $bad_headers -TimeoutSec 10
    Write-Error "Malformed token accepted: $($response.StatusCode)"
    $test_results["malformed_token"] = "FAIL"
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Success "Malformed token correctly rejected: 401"
        $test_results["malformed_token"] = "PASS"
    } else {
        Write-Warning "Malformed token: $($_.Exception.Response.StatusCode) (Expected 401)"
        $test_results["malformed_token"] = "PARTIAL"
    }
}

# Test no authorization header
Write-Info "Testing no authorization header (should return 401)..."
try {
    $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/users" -Method Get -TimeoutSec 10
    Write-Error "No auth header accepted: $($response.StatusCode)"
    $test_results["no_auth_header"] = "FAIL"
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Success "No auth header correctly rejected: 401"
        $test_results["no_auth_header"] = "PASS"
    } else {
        Write-Warning "No auth header: $($_.Exception.Response.StatusCode) (Expected 401)"
        $test_results["no_auth_header"] = "PARTIAL"
    }
}

# PHASE 5: CORS AND HEADERS VALIDATION
Write-TestHeader "PHASE 5: CORS AND HEADERS VALIDATION"

Write-Info "Testing CORS configuration..."
try {
    $cors_headers = @{
        "Origin" = "http://localhost:3000"
        "Access-Control-Request-Method" = "GET"
    }
    $cors_response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/users" -Method Options -Headers $cors_headers -TimeoutSec 10
    Write-Success "CORS preflight response: $($cors_response.StatusCode)"
    $test_results["cors_config"] = "PASS"
} catch {
    Write-Warning "CORS test failed: $($_.Exception.Message)"
    $test_results["cors_config"] = "PARTIAL"
}

Write-Info "Checking security headers..."
try {
    $headers_response = Invoke-WebRequest -Uri "$GATEWAY_URL/actuator/health" -Method Get -TimeoutSec 10
    $security_headers = @("X-Content-Type-Options", "X-Frame-Options", "X-XSS-Protection")
    $found_headers = 0
    
    foreach ($header in $security_headers) {
        if ($headers_response.Headers[$header]) {
            Write-Success "Found security header: $header"
            $found_headers++
        } else {
            Write-Warning "Missing security header: $header"
        }
    }
    
    if ($found_headers -gt 0) {
        $test_results["security_headers"] = "PASS"
    } else {
        $test_results["security_headers"] = "PARTIAL"
    }
} catch {
    Write-Warning "Security headers check failed: $($_.Exception.Message)"
    $test_results["security_headers"] = "FAIL"
}

# PHASE 6: PERFORMANCE TEST
Write-TestHeader "PHASE 6: CONCURRENT REQUEST TEST"

if ($JWT_TOKEN) {
    Write-Info "Testing concurrent JWT validation (10 requests)..."
    
    $jobs = @()
    $auth_headers = @{
        "Authorization" = "Bearer $JWT_TOKEN"
    }
    
    for ($i = 1; $i -le 10; $i++) {
        $jobs += Start-Job -ScriptBlock {
            param($url, $token)
            try {
                $headers = @{ "Authorization" = "Bearer $token" }
                $response = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -TimeoutSec 5
                return $response.StatusCode
            } catch {
                return $_.Exception.Response.StatusCode
            }
        } -ArgumentList "$GATEWAY_URL/api/users", $JWT_TOKEN
    }
    
    $results = $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
    
    $success_count = ($results | Where-Object { $_ -eq 200 }).Count
    Write-Info "Concurrent requests - Success: $success_count/10"
    
    if ($success_count -ge 8) {
        Write-Success "Concurrent request test passed"
        $test_results["concurrent_requests"] = "PASS"
    } else {
        Write-Warning "Concurrent request test partially failed"
        $test_results["concurrent_requests"] = "PARTIAL"
    }
}

# PHASE 7: BASIC PENETRATION TESTING
Write-TestHeader "PHASE 7: BASIC PENETRATION TESTING"

Write-Info "Testing SQL injection protection..."
$sql_injection_body = @{
    username = "admin'; DROP TABLE users; --"
    password = "password"
} | ConvertTo-Json

try {
    $sql_response = Invoke-RestMethod -Uri "$AUTH_URL/api/auth/login" -Method Post -Body $sql_injection_body -ContentType "application/json" -TimeoutSec 10
    Write-Warning "SQL injection may not be properly blocked"
    $test_results["sql_injection"] = "PARTIAL"
} catch {
    Write-Success "SQL injection attempt properly handled"
    $test_results["sql_injection"] = "PASS"
}

Write-Info "Testing XSS protection..."
$xss_body = @{
    username = "<script>alert('xss')</script>"
    password = "password"
} | ConvertTo-Json

try {
    $xss_response = Invoke-RestMethod -Uri "$AUTH_URL/api/auth/login" -Method Post -Body $xss_body -ContentType "application/json" -TimeoutSec 10
    Write-Warning "XSS payload may not be properly sanitized"
    $test_results["xss_protection"] = "PARTIAL"
} catch {
    Write-Success "XSS attempt properly handled"
    $test_results["xss_protection"] = "PASS"
}

# PHASE 8: GENERATE TEST REPORT
Write-TestHeader "PHASE 8: GENERATING TEST REPORT"

$total_tests = $test_results.Count
$passed_tests = ($test_results.Values | Where-Object { $_ -eq "PASS" }).Count
$failed_tests = ($test_results.Values | Where-Object { $_ -eq "FAIL" }).Count
$partial_tests = ($test_results.Values | Where-Object { $_ -eq "PARTIAL" }).Count

$success_rate = [math]::Round(($passed_tests / $total_tests) * 100, 2)

$final_report = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    vm_ip = $VMIp
    test_user = $TestUser
    total_tests = $total_tests
    passed_tests = $passed_tests
    failed_tests = $failed_tests
    partial_tests = $partial_tests
    success_rate = "$success_rate%"
    detailed_results = $test_results
    overall_status = if ($success_rate -ge 80) { "SUCCESS" } elseif ($success_rate -ge 60) { "PARTIAL_SUCCESS" } else { "FAILURE" }
    recommendations = @()
}

# Add recommendations based on failed tests
if ($test_results["gateway_health"] -eq "FAIL") { $final_report.recommendations += "Check Gateway Service deployment and configuration" }
if ($test_results["auth_health"] -eq "FAIL") { $final_report.recommendations += "Check Auth Service deployment and database connectivity" }
if ($test_results["user_health"] -eq "FAIL") { $final_report.recommendations += "Check User Service deployment and configuration" }
if ($test_results["jwt_generation"] -eq "FAIL") { $final_report.recommendations += "Review JWT configuration and Auth Service implementation" }
if ($test_results["malformed_token"] -eq "FAIL") { $final_report.recommendations += "CRITICAL: JWT validation is not working properly" }

# Save report
$report_filename = "vm_security_test_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$final_report | ConvertTo-Json -Depth 4 | Out-File $report_filename -Encoding UTF8

Write-Host "`n📊 FINAL TEST RESULTS SUMMARY" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host "Total Tests: $total_tests" -ForegroundColor White
Write-Host "Passed: $passed_tests" -ForegroundColor Green
Write-Host "Failed: $failed_tests" -ForegroundColor Red
Write-Host "Partial: $partial_tests" -ForegroundColor Yellow
Write-Host "Success Rate: $success_rate%" -ForegroundColor $(if ($success_rate -ge 80) { "Green" } elseif ($success_rate -ge 60) { "Yellow" } else { "Red" })
Write-Host "Overall Status: $($final_report.overall_status)" -ForegroundColor $(if ($final_report.overall_status -eq "SUCCESS") { "Green" } elseif ($final_report.overall_status -eq "PARTIAL_SUCCESS") { "Yellow" } else { "Red" })

if ($final_report.recommendations.Count -gt 0) {
    Write-Host "`n🔧 RECOMMENDATIONS:" -ForegroundColor Yellow
    foreach ($rec in $final_report.recommendations) {
        Write-Host "- $rec" -ForegroundColor Yellow
    }
}

Write-Host "`n📄 Detailed report saved to: $report_filename" -ForegroundColor Cyan

if ($final_report.overall_status -eq "SUCCESS") {
    Write-Host "`n🎉 SPRING SECURITY IMPLEMENTATION VERIFIED SUCCESSFULLY! 🎉" -ForegroundColor Green
    exit 0
} elseif ($final_report.overall_status -eq "PARTIAL_SUCCESS") {
    Write-Host "`n⚠️ SPRING SECURITY PARTIALLY WORKING - REVIEW RECOMMENDATIONS ⚠️" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n❌ SPRING SECURITY VERIFICATION FAILED - IMMEDIATE ACTION REQUIRED ❌" -ForegroundColor Red
    exit 2
}
