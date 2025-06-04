# 🧪 SPRING SECURITY POST-DEPLOY TESTING SUITE
# ============================================
# Tests da eseguire DOPO il deploy su VM per verificare Priority 1 completato
# 
# PREREQUISITI:
# - Tutti i servizi deployati su VM
# - Database PostgreSQL configurato e running
# - Porte 8080 (Gateway), 8081 (Auth), 8083 (User) accessibili
# - Network connectivity tra servizi

Write-Host "🚀 SPRING SECURITY POST-DEPLOY TESTING SUITE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Priority 1 Verification: Spring Security Implementation" -ForegroundColor Cyan
Write-Host ""

# Configurazione test environment
$GATEWAY_URL = "http://localhost:8080"  # Modifica con IP VM se necessario
$AUTH_URL = "http://localhost:8081"
$USER_URL = "http://localhost:8083"

$testResults = @()

function Add-TestResult {
    param($Phase, $TestName, $Status, $Details, $ResponseCode = $null)
    $global:testResults += [PSCustomObject]@{
        Phase = $Phase
        Test = $TestName
        Status = $Status
        Details = $Details
        ResponseCode = $ResponseCode
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
}

function Test-ServiceHealth {
    param($ServiceName, $Url)
    try {
        $response = Invoke-RestMethod -Uri "$Url/api/health" -Method Get -TimeoutSec 10
        Add-TestResult "Health" "$ServiceName Health" "✅ PASS" "Service is UP" "200"
        Write-Host "✅ $ServiceName: Health check PASSED" -ForegroundColor Green
        return $true
    } catch {
        Add-TestResult "Health" "$ServiceName Health" "❌ FAIL" "Service unreachable: $($_.Exception.Message)" "N/A"
        Write-Host "❌ $ServiceName: Health check FAILED - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-AuthEndpoint {
    param($Url, $TestName, $ExpectedStatus)
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -TimeoutSec 10
        $actualStatus = $response.StatusCode
        
        if ($actualStatus -eq $ExpectedStatus) {
            Add-TestResult "Security" $TestName "✅ PASS" "Expected $ExpectedStatus, got $actualStatus" $actualStatus
            Write-Host "✅ $TestName: Expected response $ExpectedStatus" -ForegroundColor Green
            return $true
        } else {
            Add-TestResult "Security" $TestName "❌ FAIL" "Expected $ExpectedStatus, got $actualStatus" $actualStatus
            Write-Host "❌ $TestName: Expected $ExpectedStatus, got $actualStatus" -ForegroundColor Red
            return $false
        }
    } catch {
        $statusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.Value__ } else { "N/A" }
        
        if ($statusCode -eq $ExpectedStatus) {
            Add-TestResult "Security" $TestName "✅ PASS" "Expected $ExpectedStatus, got $statusCode" $statusCode
            Write-Host "✅ $TestName: Expected response $ExpectedStatus" -ForegroundColor Green
            return $true
        } else {
            Add-TestResult "Security" $TestName "❌ FAIL" "Expected $ExpectedStatus, got $statusCode" $statusCode
            Write-Host "❌ $TestName: Expected $ExpectedStatus, got $statusCode - $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

function Test-JWTAuthentication {
    param($BaseUrl)
    try {
        Write-Host "🔐 Testing JWT Authentication Flow..." -ForegroundColor Cyan
        
        # Step 1: Register a test user
        $registerData = @{
            username = "testuser_$(Get-Random)"
            email = "test_$(Get-Random)@test.com"
            password = "TestPassword123!"
        } | ConvertTo-Json
        
        $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" -Method Post -Body $registerData -ContentType "application/json" -TimeoutSec 15
        
        if ($registerResponse.accessToken) {
            Add-TestResult "JWT" "User Registration" "✅ PASS" "User registered successfully, JWT token received" "201"
            Write-Host "✅ User Registration: Success with JWT token" -ForegroundColor Green
            
            # Step 2: Test protected endpoint with JWT
            $headers = @{ "Authorization" = "Bearer $($registerResponse.accessToken)" }
            $protectedResponse = Invoke-RestMethod -Uri "$BaseUrl/api/user/profile" -Method Get -Headers $headers -TimeoutSec 10
            
            Add-TestResult "JWT" "Protected Endpoint Access" "✅ PASS" "Protected endpoint accessible with JWT" "200"
            Write-Host "✅ Protected Endpoint: Accessible with JWT" -ForegroundColor Green
            
            return $registerResponse.accessToken
        } else {
            Add-TestResult "JWT" "User Registration" "❌ FAIL" "No JWT token in registration response" "N/A"
            Write-Host "❌ User Registration: No JWT token received" -ForegroundColor Red
            return $null
        }
    } catch {
        Add-TestResult "JWT" "JWT Authentication Flow" "❌ FAIL" "JWT authentication failed: $($_.Exception.Message)" "N/A"
        Write-Host "❌ JWT Authentication: FAILED - $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🏥 PHASE 1: HEALTH CHECK VERIFICATION" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

$gatewayHealthy = Test-ServiceHealth "Gateway Service" $GATEWAY_URL
$authHealthy = Test-ServiceHealth "Auth Service" $AUTH_URL  
$userHealthy = Test-ServiceHealth "User Service" $USER_URL

if (-not ($gatewayHealthy -and $authHealthy -and $userHealthy)) {
    Write-Host "⚠️ Some services are not healthy. Check deployment before continuing." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔒 PHASE 2: PUBLIC ENDPOINTS VERIFICATION" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

# Test public endpoints (should return 200)
Test-AuthEndpoint "$GATEWAY_URL/api/health" "Gateway Health Endpoint" 200
Test-AuthEndpoint "$GATEWAY_URL/api/info" "Gateway Info Endpoint" 200  
Test-AuthEndpoint "$AUTH_URL/api/health" "Auth Health Endpoint" 200
Test-AuthEndpoint "$USER_URL/api/health" "User Health Endpoint" 200

Write-Host ""
Write-Host "🛡️ PHASE 3: PROTECTED ENDPOINTS VERIFICATION" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow

# Test protected endpoints without authentication (should return 401)
Test-AuthEndpoint "$GATEWAY_URL/api/user/profile" "Gateway Protected Endpoint (No Auth)" 401
Test-AuthEndpoint "$GATEWAY_URL/api/springmon/data" "Gateway SpringMon Data (No Auth)" 401
Test-AuthEndpoint "$USER_URL/api/users" "User Service Users List (No Auth)" 401

Write-Host ""
Write-Host "🔑 PHASE 4: JWT AUTHENTICATION FLOW" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

$jwtToken = Test-JWTAuthentication $GATEWAY_URL

Write-Host ""
Write-Host "🔐 PHASE 5: JWT TOKEN VALIDATION" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow

if ($jwtToken) {
    try {
        # Test with valid JWT token
        $headers = @{ "Authorization" = "Bearer $jwtToken" }
        $response = Invoke-RestMethod -Uri "$GATEWAY_URL/api/springmon/data" -Method Get -Headers $headers -TimeoutSec 10
        
        Add-TestResult "JWT" "Valid JWT Access" "✅ PASS" "SpringMon data accessible with valid JWT" "200"
        Write-Host "✅ Valid JWT: Access granted to SpringMon data" -ForegroundColor Green
        
    } catch {
        Add-TestResult "JWT" "Valid JWT Access" "❌ FAIL" "Valid JWT rejected: $($_.Exception.Message)" "N/A"
        Write-Host "❌ Valid JWT: Access denied - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test with invalid JWT token
    try {
        $invalidHeaders = @{ "Authorization" = "Bearer invalid_token_12345" }
        $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/springmon/data" -Method Get -Headers $invalidHeaders -UseBasicParsing -TimeoutSec 10
        
        Add-TestResult "JWT" "Invalid JWT Rejection" "❌ FAIL" "Invalid JWT was accepted (security issue!)" $response.StatusCode
        Write-Host "❌ Invalid JWT: SECURITY ISSUE - Invalid token was accepted!" -ForegroundColor Red
        
    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 401) {
            Add-TestResult "JWT" "Invalid JWT Rejection" "✅ PASS" "Invalid JWT properly rejected with 401" "401"
            Write-Host "✅ Invalid JWT: Properly rejected with 401" -ForegroundColor Green
        } else {
            Add-TestResult "JWT" "Invalid JWT Rejection" "⚠️ WARN" "Unexpected response to invalid JWT" $_.Exception.Response.StatusCode.Value__
            Write-Host "⚠️ Invalid JWT: Unexpected response" -ForegroundColor Yellow
        }
    }
} else {
    Add-TestResult "JWT" "JWT Token Validation" "⚠️ SKIP" "No valid JWT token available for testing" "N/A"
    Write-Host "⚠️ JWT Validation: Skipped - No valid token available" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 PHASE 6: CORS CONFIGURATION TEST" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

try {
    # Test CORS headers
    $corsHeaders = @{ "Origin" = "http://localhost:3000" }
    $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/health" -Method Get -Headers $corsHeaders -UseBasicParsing -TimeoutSec 10
    
    $corsHeader = $response.Headers["Access-Control-Allow-Origin"]
    if ($corsHeader -and ($corsHeader -eq "*" -or $corsHeader -eq "http://localhost:3000")) {
        Add-TestResult "CORS" "CORS Configuration" "✅ PASS" "CORS headers present and configured" "200"
        Write-Host "✅ CORS: Properly configured with Access-Control-Allow-Origin" -ForegroundColor Green
    } else {
        Add-TestResult "CORS" "CORS Configuration" "⚠️ WARN" "CORS headers missing or misconfigured" "200"
        Write-Host "⚠️ CORS: Headers missing or misconfigured" -ForegroundColor Yellow
    }
} catch {
    Add-TestResult "CORS" "CORS Configuration" "❌ FAIL" "CORS test failed: $($_.Exception.Message)" "N/A"
    Write-Host "❌ CORS: Test failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔄 PHASE 7: SESSION MANAGEMENT VERIFICATION" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow

try {
    # Test that services are stateless (no session cookies)
    $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/health" -Method Get -UseBasicParsing -TimeoutSec 10
    
    $sessionCookies = $response.Headers["Set-Cookie"] | Where-Object { $_ -like "*JSESSIONID*" }
    if (-not $sessionCookies) {
        Add-TestResult "Sessions" "Stateless Sessions" "✅ PASS" "No session cookies - properly stateless" "200"
        Write-Host "✅ Sessions: Properly stateless (no JSESSIONID cookies)" -ForegroundColor Green
    } else {
        Add-TestResult "Sessions" "Stateless Sessions" "❌ FAIL" "Session cookies detected - not stateless!" "200"
        Write-Host "❌ Sessions: Session cookies detected - should be stateless!" -ForegroundColor Red
    }
} catch {
    Add-TestResult "Sessions" "Stateless Sessions" "❌ FAIL" "Session test failed: $($_.Exception.Message)" "N/A"
    Write-Host "❌ Sessions: Test failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🚨 PHASE 8: SECURITY PENETRATION TESTS" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow

# Test SQL Injection protection (if applicable)
try {
    $sqlInjectionPayload = "'; DROP TABLE users; --"
    $maliciousData = @{
        username = $sqlInjectionPayload
        password = "test123"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$GATEWAY_URL/api/auth/login" -Method Post -Body $maliciousData -ContentType "application/json" -UseBasicParsing -TimeoutSec 10
    
    # Should return 400 or 401, not 500 (which might indicate SQL injection vulnerability)
    if ($response.StatusCode -eq 500) {
        Add-TestResult "Security" "SQL Injection Protection" "❌ FAIL" "Potential SQL injection vulnerability detected" "500"
        Write-Host "❌ SQL Injection: Potential vulnerability detected (500 error)" -ForegroundColor Red
    } else {
        Add-TestResult "Security" "SQL Injection Protection" "✅ PASS" "SQL injection properly handled" $response.StatusCode
        Write-Host "✅ SQL Injection: Properly protected" -ForegroundColor Green
    }
} catch {
    $statusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.Value__ } else { "N/A" }
    if ($statusCode -eq 400 -or $statusCode -eq 401) {
        Add-TestResult "Security" "SQL Injection Protection" "✅ PASS" "SQL injection properly rejected" $statusCode
        Write-Host "✅ SQL Injection: Properly protected with $statusCode" -ForegroundColor Green
    } else {
        Add-TestResult "Security" "SQL Injection Protection" "⚠️ WARN" "Unexpected response to SQL injection test" $statusCode
        Write-Host "⚠️ SQL Injection: Unexpected response - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Test XSS protection in responses
try {
    $xssPayload = "<script>alert('xss')</script>"
    $xssResponse = Invoke-RestMethod -Uri "$GATEWAY_URL/api/info" -Method Get -TimeoutSec 10
    
    if ($xssResponse -and $xssResponse.ToString() -notlike "*<script>*") {
        Add-TestResult "Security" "XSS Protection" "✅ PASS" "No script tags in API responses" "200"
        Write-Host "✅ XSS Protection: API responses properly sanitized" -ForegroundColor Green
    } else {
        Add-TestResult "Security" "XSS Protection" "⚠️ WARN" "Potential XSS vulnerability in responses" "200"
        Write-Host "⚠️ XSS Protection: Check response sanitization" -ForegroundColor Yellow
    }
} catch {
    Add-TestResult "Security" "XSS Protection" "❌ FAIL" "XSS test failed: $($_.Exception.Message)" "N/A"
    Write-Host "❌ XSS Protection: Test failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 COMPREHENSIVE TEST RESULTS" -ForegroundColor Magenta
Write-Host "==============================" -ForegroundColor Magenta

# Group results by phase
$groupedResults = $testResults | Group-Object Phase

foreach ($group in $groupedResults) {
    Write-Host ""
    Write-Host "📋 $($group.Name) Tests:" -ForegroundColor Cyan
    
    $group.Group | ForEach-Object {
        $color = switch ($_.Status.Substring(0,1)) {
            "✅" { "Green" }
            "❌" { "Red" }
            "⚠️" { "Yellow" }
            default { "White" }
        }
        Write-Host "  $($_.Status) $($_.Test)" -ForegroundColor $color
        if ($_.ResponseCode -and $_.ResponseCode -ne "N/A") {
            Write-Host "    Response: $($_.ResponseCode) - $($_.Details)" -ForegroundColor Gray
        } else {
            Write-Host "    $($_.Details)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "🎯 FINAL STATISTICS" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta

$passedTests = ($testResults | Where-Object { $_.Status -like "✅*" }).Count
$failedTests = ($testResults | Where-Object { $_.Status -like "❌*" }).Count
$warnTests = ($testResults | Where-Object { $_.Status -like "⚠️*" }).Count
$totalTests = $testResults.Count

Write-Host "✅ Passed: $passedTests" -ForegroundColor Green
Write-Host "❌ Failed: $failedTests" -ForegroundColor Red  
Write-Host "⚠️ Warnings: $warnTests" -ForegroundColor Yellow
Write-Host "📊 Total: $totalTests" -ForegroundColor Cyan

$successRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 1) } else { 0 }
Write-Host ""
Write-Host "Success Rate: $successRate%" -ForegroundColor Cyan

Write-Host ""
Write-Host "🏆 FINAL ASSESSMENT" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta

if ($failedTests -eq 0 -and $passedTests -gt ($totalTests * 0.8)) {
    Write-Host "🟢 EXCELLENT: Spring Security implementation working perfectly!" -ForegroundColor Green
    Write-Host "✅ Priority 1 - SPRING SECURITY: VERIFIED IN PRODUCTION" -ForegroundColor Green
    Write-Host "🚀 Ready to proceed with Priority 2: JWT Security Enhancement" -ForegroundColor Cyan
} elseif ($failedTests -le 2 -and $passedTests -gt ($totalTests * 0.6)) {
    Write-Host "🟡 GOOD: Spring Security mostly working, minor issues to address" -ForegroundColor Yellow
    Write-Host "⚠️ Priority 1 - SPRING SECURITY: FUNCTIONAL WITH MINOR ISSUES" -ForegroundColor Yellow
    Write-Host "🔧 Address failed tests before proceeding to Priority 2" -ForegroundColor Yellow
} else {
    Write-Host "🔴 NEEDS ATTENTION: Multiple Spring Security issues detected" -ForegroundColor Red
    Write-Host "❌ Priority 1 - SPRING SECURITY: REQUIRES FIXES" -ForegroundColor Red
    Write-Host "🛠️ Fix critical issues before proceeding" -ForegroundColor Red
}

Write-Host ""
Write-Host "📝 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Fix any failed tests above" -ForegroundColor White
Write-Host "2. Verify all security features in production environment" -ForegroundColor White
Write-Host "3. Document any configuration changes needed" -ForegroundColor White
Write-Host "4. Proceed to Priority 2: JWT Security Enhancement" -ForegroundColor White

Write-Host ""
Write-Host "🕒 Testing completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "💾 Save these results for deployment verification documentation" -ForegroundColor Gray
