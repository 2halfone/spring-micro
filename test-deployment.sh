#!/bin/bash

# Test Deployment Script for SpringMon
# Usage: ./test-deployment.sh

echo "🧪 Testing SpringMon Deployment"
echo "================================"

# Configuration
VM_HOST="34.140.122.146"
GATEWAY_PORT="8080"
AUTH_PORT="8081"
USER_PORT="8082"

echo "🌐 Testing VM: $VM_HOST"
echo ""

# Function to test endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_code=${3:-200}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "$expected_code" ]; then
        echo "✅ SUCCESS (HTTP $response)"
    else
        echo "❌ FAILED (HTTP $response, expected $expected_code)"
    fi
}

# Test basic connectivity
echo "🔍 Testing basic connectivity..."
ping -c 1 $VM_HOST > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ VM is reachable"
else
    echo "❌ VM is not reachable"
    exit 1
fi
echo ""

# Test Gateway Service
echo "🚪 Testing Gateway Service..."
test_endpoint "http://$VM_HOST:$GATEWAY_PORT/actuator/health" "Gateway Health Endpoint"
test_endpoint "http://$VM_HOST:$GATEWAY_PORT/api/health" "API Health Endpoint"
echo ""

# Test Auth Service (through Gateway)
echo "🔐 Testing Auth Service..."
test_endpoint "http://$VM_HOST:$GATEWAY_PORT/api/auth/health" "Auth Health Endpoint"
echo ""

# Test User Service (through Gateway)
echo "👤 Testing User Service..."
test_endpoint "http://$VM_HOST:$GATEWAY_PORT/api/users" "Protected Users Endpoint" "401"
echo ""

# Test Authentication Flow
echo "🔑 Testing Authentication Flow..."

# Register a test user
echo -n "Registering test user... "
register_response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","email":"test@example.com","password":"password123"}' \
    "http://$VM_HOST:$GATEWAY_PORT/api/auth/register" 2>/dev/null)

register_code=$(echo "$register_response" | tail -c 4)
if [ "$register_code" = "201" ] || [ "$register_code" = "200" ] || [ "$register_code" = "409" ]; then
    echo "✅ SUCCESS (HTTP $register_code)"
else
    echo "❌ FAILED (HTTP $register_code)"
fi

# Login with test user
echo -n "Logging in test user... "
login_response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","password":"password123"}' \
    "http://$VM_HOST:$GATEWAY_PORT/api/auth/login" 2>/dev/null)

login_code=$(echo "$login_response" | tail -n 1)
if [ "$login_code" = "200" ]; then
    echo "✅ SUCCESS (HTTP $login_code)"
    
    # Extract token from response
    token=$(echo "$login_response" | head -n -1 | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$token" ]; then
        echo "✅ JWT Token received"
        
        # Test protected endpoint with token
        echo -n "Testing protected endpoint with token... "
        protected_response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $token" \
            "http://$VM_HOST:$GATEWAY_PORT/api/users" 2>/dev/null)
        
        if [ "$protected_response" = "200" ]; then
            echo "✅ SUCCESS (HTTP $protected_response)"
        else
            echo "❌ FAILED (HTTP $protected_response)"
        fi
    else
        echo "⚠️ No token in response"
    fi
else
    echo "❌ FAILED (HTTP $login_code)"
fi

echo ""
echo "🏁 Deployment Test Summary"
echo "========================="
echo "Gateway: http://$VM_HOST:$GATEWAY_PORT"
echo "Health Check: http://$VM_HOST:$GATEWAY_PORT/api/health"
echo "API Docs: http://$VM_HOST:$GATEWAY_PORT/swagger-ui.html"
echo ""
echo "✨ Test completed!"
