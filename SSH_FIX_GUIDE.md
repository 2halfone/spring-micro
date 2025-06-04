# 🔧 SSH Key Troubleshooting Guide

## 🚨 Current Issue: Permission denied (publickey)

The GitHub Actions workflow shows:
- ✅ SSH key format is valid (3389 bytes)
- ✅ All secrets are configured 
- ❌ SSH connection fails with "Permission denied (publickey)"

This means the **private key is correctly formatted** but the **public key is not properly configured on the VM**.

## 🔑 Step-by-Step Solution

### 1. Generate a Fresh SSH Key Pair

Open PowerShell and run:

```powershell
# Navigate to SSH directory
cd $env:USERPROFILE\.ssh

# Generate new key pair specifically for SpringMon deployment
ssh-keygen -t rsa -b 4096 -f springmon_deploy_key -C "springmon-deploy@github-actions"

# When prompted:
# - Enter file name: springmon_deploy_key (already set)
# - Enter passphrase: [Leave empty - press Enter twice]
```

### 2. Copy Public Key to VM

```powershell
# Display the public key (copy this output)
Get-Content $env:USERPROFILE\.ssh\springmon_deploy_key.pub
```

**Copy the entire output** (starts with `ssh-rsa AAAA...`)

### 3. Add Public Key to VM

Connect to your VM and run:

```bash
# SSH to your VM first (using your current method)
ssh frazerfrax1@34.140.122.146

# Once on the VM, add the public key
mkdir -p ~/.ssh
echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Verify the key was added
cat ~/.ssh/authorized_keys
```

### 4. Test Local SSH Connection

Back on your local machine:

```powershell
# Test the new SSH key
ssh -i $env:USERPROFILE\.ssh\springmon_deploy_key frazerfrax1@34.140.122.146 "echo 'SSH connection successful'"
```

### 5. Update GitHub Secret

1. Copy the **private key** content:
```powershell
Get-Content $env:USERPROFILE\.ssh\springmon_deploy_key
```

2. Go to GitHub: **Repository → Settings → Secrets and variables → Actions**

3. **Edit** the `DEPLOY_KEY` secret and replace with the new private key content

## 🧪 Quick Test Script

Save this as `test-ssh-fix.ps1`:

```powershell
# Test the new SSH key configuration
$privateKey = "$env:USERPROFILE\.ssh\springmon_deploy_key"
$publicKey = "$env:USERPROFILE\.ssh\springmon_deploy_key.pub"
$vmHost = "34.140.122.146"
$vmUser = "frazerfrax1"

Write-Host "🔍 SSH Key Configuration Test" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if keys exist
if (!(Test-Path $privateKey)) {
    Write-Host "❌ Private key not found: $privateKey" -ForegroundColor Red
    Write-Host "Run: ssh-keygen -t rsa -b 4096 -f springmon_deploy_key" -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $publicKey)) {
    Write-Host "❌ Public key not found: $publicKey" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SSH keys found" -ForegroundColor Green

# Show public key for VM setup
Write-Host "`n📋 Public key to add to VM:" -ForegroundColor Cyan
Get-Content $publicKey
Write-Host ""

# Test SSH connection
Write-Host "🔍 Testing SSH connection..." -ForegroundColor Cyan
try {
    $result = ssh -i $privateKey -o StrictHostKeyChecking=no $vmUser@$vmHost "echo 'SSH test successful'; whoami"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful!" -ForegroundColor Green
        Write-Host "Response: $result" -ForegroundColor White
        
        Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
        Write-Host "1. Copy private key content to GitHub DEPLOY_KEY secret" -ForegroundColor White
        Write-Host "2. Push a new commit to trigger deployment" -ForegroundColor White
    } else {
        Write-Host "❌ SSH connection failed!" -ForegroundColor Red
        Write-Host "Make sure you added the public key to the VM's ~/.ssh/authorized_keys" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ SSH test error: $_" -ForegroundColor Red
}
```

## 🚀 Quick Resolution Commands

Run these commands in sequence:

```powershell
# 1. Generate new key
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\springmon_deploy_key -N '""'

# 2. Show public key (copy this to VM)
Write-Host "📋 Copy this public key to VM:" -ForegroundColor Yellow
Get-Content $env:USERPROFILE\.ssh\springmon_deploy_key.pub

# 3. Show private key (copy this to GitHub Secret)
Write-Host "`n🔑 Copy this private key to GitHub DEPLOY_KEY secret:" -ForegroundColor Yellow
Get-Content $env:USERPROFILE\.ssh\springmon_deploy_key
```

## ⚠️ Important Notes

- **Never share the private key** - only add it to GitHub Secrets
- **The public key goes on the VM** in `~/.ssh/authorized_keys`
- **Test locally first** before updating GitHub Secrets
- **Use a key without passphrase** for automated deployment

After fixing the SSH key, your GitHub Actions workflow should succeed!
