#!/bin/bash

# 🔑 SSH Connection Test Script for SpringMon Deployment
# Run this script to test SSH connection before using GitHub Actions

set -e

# Configuration
DEPLOY_HOST="34.140.122.146"
DEPLOY_USER="frazerfrax1"
DEPLOY_PATH="/opt/springmon"

echo "🔍 SpringMon SSH Connection Test"
echo "================================"
echo "Host: $DEPLOY_HOST"
echo "User: $DEPLOY_USER"
echo "Path: $DEPLOY_PATH"
echo ""

# Check if SSH key file exists
if [ ! -f "key.pem" ]; then
    echo "❌ SSH key file 'key.pem' not found!"
    echo "Please create the SSH private key file as 'key.pem' in this directory"
    echo ""
    echo "Example:"
    echo "  1. Copy your private key content to 'key.pem'"
    echo "  2. chmod 600 key.pem"
    echo "  3. Run this script again"
    exit 1
fi

echo "✅ SSH key file found"

# Set proper permissions
chmod 600 key.pem
echo "✅ SSH key permissions set to 600"

# Validate SSH key format
echo "🔍 Validating SSH key format..."
if ! ssh-keygen -l -f key.pem > /dev/null 2>&1; then
    echo "❌ Invalid SSH key format!"
    echo "Key must be in OpenSSH format:"
    echo "  - Start with: -----BEGIN OPENSSH PRIVATE KEY-----"
    echo "  - End with: -----END OPENSSH PRIVATE KEY-----"
    exit 1
fi

echo "✅ SSH key format is valid"

# Test basic connectivity
echo "🔍 Testing basic network connectivity..."
if ! ping -c 1 $DEPLOY_HOST > /dev/null 2>&1; then
    echo "❌ Cannot reach host $DEPLOY_HOST"
    echo "Check network connectivity and host IP"
    exit 1
fi

echo "✅ Host is reachable"

# Test SSH connection
echo "🔍 Testing SSH connection..."
if ssh -i key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=10 $DEPLOY_USER@$DEPLOY_HOST "echo 'SSH connection successful'"; then
    echo "✅ SSH connection successful!"
else
    echo "❌ SSH connection failed!"
    echo ""
    echo "Common issues:"
    echo "  1. Wrong SSH key format (use OpenSSH, not PuTTY)"
    echo "  2. Public key not added to ~/.ssh/authorized_keys on VM"
    echo "  3. Wrong username (should be: $DEPLOY_USER)"
    echo "  4. SSH service not running on VM"
    echo "  5. Firewall blocking SSH port 22"
    exit 1
fi

# Test deployment directory access
echo "🔍 Testing deployment directory access..."
ssh -i key.pem -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST "
    sudo mkdir -p $DEPLOY_PATH || { echo 'Cannot create deployment directory'; exit 1; }
    sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_PATH || { echo 'Cannot change directory ownership'; exit 1; }
    ls -la $DEPLOY_PATH || { echo 'Cannot list deployment directory'; exit 1; }
    echo 'Deployment directory access: OK'
"

echo "✅ Deployment directory access successful"

# Test Docker availability
echo "🔍 Testing Docker availability..."
ssh -i key.pem -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST "
    docker --version || { echo 'Docker not installed'; exit 1; }
    docker-compose --version || { echo 'Docker Compose not installed'; exit 1; }
    docker info > /dev/null 2>&1 || { echo 'Docker daemon not running or no permissions'; exit 1; }
    echo 'Docker environment: OK'
"

echo "✅ Docker environment ready"

# Final success message
echo ""
echo "🎉 All SSH connection tests passed!"
echo ""
echo "✅ Ready for GitHub Actions deployment"
echo ""
echo "Next steps:"
echo "  1. Copy the SSH private key content (from key.pem) to GitHub Secret 'DEPLOY_KEY'"
echo "  2. Set GitHub Secret 'DEPLOY_HOST' to: $DEPLOY_HOST"
echo "  3. Set GitHub Secret 'DEPLOY_USER' to: $DEPLOY_USER"
echo "  4. Push your changes to trigger the GitHub Actions workflow"
echo ""
echo "🔗 GitHub Secrets: Repository → Settings → Secrets and variables → Actions"
