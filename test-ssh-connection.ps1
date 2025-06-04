# 🔧 Test SSH Connection to VM
# Questo script testa la connessione SSH alla VM prima del deploy

param(
    [string]$KeyPath = "$env:USERPROFILE\.ssh\id_rsa",
    [string]$Host = "34.140.122.146",
    [string]$User = "frazerfrax1"
)

Write-Host "🔑 Testing SSH Connection to SpringMon VM" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check if SSH key exists
if (-not (Test-Path $KeyPath)) {
    Write-Host "❌ SSH key not found at: $KeyPath" -ForegroundColor Red
    Write-Host "💡 Generate a new key with: ssh-keygen -t rsa -b 4096 -C 'deploy@springmon'" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ SSH key found: $KeyPath" -ForegroundColor Green

# Test SSH connection
Write-Host "🔍 Testing SSH connection to $User@$Host..." -ForegroundColor Yellow

try {
    $testResult = ssh -i $KeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 $User@$Host "echo 'SSH connection successful'; whoami; pwd; docker --version"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH Connection Successful!" -ForegroundColor Green
        Write-Host "📋 VM Info:" -ForegroundColor Cyan
        Write-Host $testResult -ForegroundColor White
        
        # Test VM environment
        Write-Host "🏗️ Checking VM environment..." -ForegroundColor Yellow
        $envCheck = ssh -i $KeyPath -o StrictHostKeyChecking=no $User@$Host "ls -la /opt/ | grep springmon || echo 'springmon directory not found'"
        Write-Host $envCheck -ForegroundColor White
        
        Write-Host ""
        Write-Host "🎉 VM is ready for deployment!" -ForegroundColor Green
        Write-Host "🚀 You can now run the GitHub Actions pipeline" -ForegroundColor Green
        
    } else {
        Write-Host "❌ SSH Connection Failed!" -ForegroundColor Red
        Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "   1. Verify the VM is running" -ForegroundColor White
        Write-Host "   2. Check if your public key is in ~/.ssh/authorized_keys on the VM" -ForegroundColor White
        Write-Host "   3. Verify the username and IP address" -ForegroundColor White
        exit 1
    }
} catch {
    Write-Host "❌ SSH test failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure GitHub Secrets (see GITHUB_SECRETS_SETUP.md)" -ForegroundColor White
Write-Host "2. Push a commit to trigger the deployment pipeline" -ForegroundColor White
Write-Host "3. Monitor the pipeline at: https://github.com/[your-repo]/actions" -ForegroundColor White
