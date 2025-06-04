# Test SSH key configuration for SpringMon deployment
param(
    [string]$KeyName = "springmon_deploy_key",
    [string]$VMHost = "34.140.122.146",
    [string]$VMUser = "frazerfrax1"
)

$privateKey = "$env:USERPROFILE\.ssh\$KeyName"
$publicKey = "$env:USERPROFILE\.ssh\$KeyName.pub"

Write-Host "🔍 SSH Key Configuration Test" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Private Key: $privateKey" -ForegroundColor White
Write-Host "Public Key: $publicKey" -ForegroundColor White
Write-Host "Target: $VMUser@$VMHost" -ForegroundColor White
Write-Host ""

# Check if keys exist
if (!(Test-Path $privateKey)) {
    Write-Host "❌ Private key not found: $privateKey" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Generate new SSH key:" -ForegroundColor Yellow
    Write-Host "ssh-keygen -t rsa -b 4096 -f `"$privateKey`" -N ''" -ForegroundColor Gray
    exit 1
}

if (!(Test-Path $publicKey)) {
    Write-Host "❌ Public key not found: $publicKey" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SSH key files found" -ForegroundColor Green

# Show key information
$keyInfo = ssh-keygen -l -f $privateKey
Write-Host "🔑 Key info: $keyInfo" -ForegroundColor Gray

# Show public key for VM setup
Write-Host ""
Write-Host "📋 PUBLIC KEY (add this to VM ~/.ssh/authorized_keys):" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Get-Content $publicKey
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Test SSH connection
Write-Host "🔍 Testing SSH connection to $VMUser@$VMHost..." -ForegroundColor Yellow

try {
    $sshTest = ssh -i $privateKey -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$VMUser@$VMHost" "echo 'SSH connection successful'; whoami; pwd"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH CONNECTION SUCCESSFUL!" -ForegroundColor Green -BackgroundColor DarkGreen
        Write-Host ""
        Write-Host "📋 SSH Response:" -ForegroundColor Cyan
        Write-Host $sshTest -ForegroundColor White
        Write-Host ""
        
        # Test deployment directory
        Write-Host "🏗️ Testing deployment directory access..." -ForegroundColor Yellow
        $deployTest = ssh -i $privateKey -o StrictHostKeyChecking=no "$VMUser@$VMHost" "sudo mkdir -p /opt/springmon && sudo chown $VMUser`:$VMUser /opt/springmon && ls -la /opt/springmon"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployment directory access OK" -ForegroundColor Green
            
            Write-Host ""
            Write-Host "🎉 SSH CONFIGURATION IS CORRECT!" -ForegroundColor Green -BackgroundColor DarkGreen
            Write-Host ""
            Write-Host "📋 Next Steps:" -ForegroundColor Cyan
            Write-Host "1. Copy the PRIVATE key content below to GitHub Secret 'DEPLOY_KEY'" -ForegroundColor White
            Write-Host "2. Ensure DEPLOY_HOST = '$VMHost'" -ForegroundColor White
            Write-Host "3. Ensure DEPLOY_USER = '$VMUser'" -ForegroundColor White
            Write-Host "4. Push a new commit to trigger deployment" -ForegroundColor White
            Write-Host ""
            Write-Host "🔑 PRIVATE KEY CONTENT (copy to GitHub DEPLOY_KEY secret):" -ForegroundColor Yellow
            Write-Host "=" * 60 -ForegroundColor Yellow
            Get-Content $privateKey
            Write-Host "=" * 60 -ForegroundColor Yellow
            
        } else {
            Write-Host "⚠️ Deployment directory access failed" -ForegroundColor Red
            Write-Host "Check sudo permissions for user $VMUser" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ SSH CONNECTION FAILED!" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔧 Troubleshooting Steps:" -ForegroundColor Yellow
        Write-Host "1. Make sure you added the PUBLIC key to the VM:" -ForegroundColor White
        Write-Host "   ssh $VMUser@$VMHost" -ForegroundColor Gray
        Write-Host "   echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "   chmod 600 ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Verify VM SSH service is running" -ForegroundColor White
        Write-Host "3. Check firewall allows SSH (port 22)" -ForegroundColor White
    }
    
} catch {
    Write-Host "❌ SSH test error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure OpenSSH client is installed:" -ForegroundColor Yellow
    Write-Host "Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔗 GitHub Repository Secrets:" -ForegroundColor Cyan
Write-Host "https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions" -ForegroundColor Blue
