# 🔑 GitHub Secrets Configuration Guide

## Critical Issue: SSH Permission Denied

The error "Permission denied (publickey)" indicates that the SSH key in your GitHub secrets is not properly formatted or configured.

## 📋 Required GitHub Secrets

Navigate to your repository → **Settings** → **Secrets and variables** → **Actions** and configure:

### 1. DEPLOY_KEY (SSH Private Key)
```
Type: Repository Secret
Name: DEPLOY_KEY
Value: [Your OpenSSH private key content]
```

**Critical Requirements:**
- Must be in OpenSSH format (not PuTTY .ppk)
- Must start with: `-----BEGIN OPENSSH PRIVATE KEY-----`
- Must end with: `-----END OPENSSH PRIVATE KEY-----`
- No Windows line endings (`\r\n` → `\n`)
- Include the entire key including headers/footers

### 2. DEPLOY_HOST
```
Type: Repository Secret
Name: DEPLOY_HOST
Value: 34.140.122.146
```

### 3. DEPLOY_USER
```
Type: Repository Secret
Name: DEPLOY_USER
Value: frazerfrax1
```

## 🔧 SSH Key Generation (if needed)

If you need to generate a new SSH key pair:

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -f ./springmon_deploy_key -N ""

# Copy public key to VM
ssh-copy-id -i ./springmon_deploy_key.pub frazerfrax1@34.140.122.146

# Use private key content for DEPLOY_KEY secret
cat ./springmon_deploy_key
```

## 🐧 VM Configuration

Make sure your VM has the public key properly installed:

```bash
# On VM (34.140.122.146)
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key to authorized_keys
echo "your-public-key-content" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Test SSH connection locally
ssh -i ./springmon_deploy_key frazerfrax1@34.140.122.146
```

## 🔍 Debug Steps

1. **Verify SSH key format** in GitHub secrets:
   - Must be OpenSSH format (not PuTTY)
   - Include complete headers/footers
   - No extra spaces or characters

2. **Test local SSH connection**:
   ```bash
   ssh -i your_key.pem frazerfrax1@34.140.122.146
   ```

3. **Check VM SSH logs**:
   ```bash
   # On VM
   sudo tail -f /var/log/auth.log
   ```

## ⚠️ Common Issues

- **PuTTY format**: Convert .ppk to OpenSSH format
- **Line endings**: Remove Windows `\r` characters
- **Permissions**: VM `~/.ssh` should be 700, `authorized_keys` should be 600
- **User mismatch**: Ensure `frazerfrax1` user exists on VM

## 🚀 Next Steps

1. ✅ Configure all 3 GitHub secrets correctly
2. ✅ Test SSH connection manually first
3. ✅ Run GitHub Actions workflow
4. ✅ Monitor deployment logs

The workflow is correctly configured - the issue is purely with SSH key authentication.
