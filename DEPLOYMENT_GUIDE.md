# 🚀 SpringMon Deployment Guide

## Overview
This document describes the GitHub Actions deployment pipeline for SpringMon microservices to VM `34.140.122.146`.

## Deployment Architecture

```
GitHub Repository (Push to main/master)
           ↓
    GitHub Actions Pipeline
           ↓
     VM (34.140.122.146)
           ↓
    Docker Compose Services
    - Gateway Service (Port 8080)
    - Auth Service (Port 8081) 
    - User Service (Port 8082)
    - PostgreSQL Database (Port 5432)
```

## Prerequisites ✅

### 1. GitHub Secrets Configuration
The following secrets must be configured in the GitHub repository:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `DEPLOY_KEY` | SSH private key for VM access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `DEPLOY_HOST` | VM IP address | `34.140.122.146` |
| `DEPLOY_USER` | SSH username on VM | `frazerfrax1` |

### 2. VM Prerequisites
- Docker and Docker Compose installed
- SSH access configured with public key authentication
- Ports 8080-8082 and 5432 open for incoming connections
- User has sudo privileges for directory creation

### 3. Repository Structure
```
springmon-microservices/
├── .github/workflows/deploy.yml    # GitHub Actions pipeline
├── docker-compose.yml              # Service orchestration
├── .env                           # Environment variables
├── gateway-service/               # API Gateway
├── auth-service/                  # Authentication service
├── user-service/                  # User management service
└── docker/                       # Database initialization
```

## Deployment Process 🔄

### Automatic Deployment
The pipeline automatically triggers on:
- Push to `main` or `master` branch
- Manual workflow dispatch from GitHub Actions tab

### Manual Deployment
To trigger deployment manually:
1. Go to GitHub Actions tab in repository
2. Select "Deploy SpringMon to VM" workflow
3. Click "Run workflow" button
4. Select branch and confirm

## Pipeline Steps 📋

1. **Checkout Code** - Downloads repository code
2. **Setup Java 17** - Configures Java environment
3. **Cache Maven Dependencies** - Speeds up builds
4. **Build Services** - Compiles all microservices (Gateway, Auth, User)
5. **Setup SSH** - Configures SSH key for VM access
6. **Test SSH Connection** - Verifies connectivity to VM
7. **Deploy to VM** - Copies files and runs docker-compose
8. **Verify Deployment** - Performs health checks

## Service URLs 🌐

After successful deployment, services are available at:

| Service | URL | Description |
|---------|-----|-------------|
| Gateway | http://34.140.122.146:8080 | Main API Gateway |
| Health Check | http://34.140.122.146:8080/api/health | System health status |
| Auth Login | http://34.140.122.146:8080/api/auth/login | User authentication |
| Auth Register | http://34.140.122.146:8080/api/auth/register | User registration |
| User API | http://34.140.122.146:8080/api/users | User management (protected) |

## Testing Deployment 🧪

### Automated Testing
Run the included test script:
```bash
chmod +x test-deployment.sh
./test-deployment.sh
```

### Manual Testing
```bash
# Health check
curl http://34.140.122.146:8080/api/health

# Register user
curl -X POST http://34.140.122.146:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# Login user
curl -X POST http://34.140.122.146:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'

# Access protected endpoint (requires JWT token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://34.140.122.146:8080/api/users
```

## Environment Configuration 🔧

### Production Environment Variables (.env)
```bash
POSTGRES_DB=springmon
POSTGRES_USER=springmon_user
POSTGRES_PASSWORD=springmon_secure_password_2024
JWT_SECRET=springmon_jwt_secret_key_2024_very_secure_random_string_256_bits
SPRING_PROFILES_ACTIVE=docker
ENVIRONMENT=production
```

### Port Configuration
- Gateway Service: 8080 (external), 8080 (internal)
- Auth Service: 8081 (external), 8081 (internal)
- User Service: 8082 (external), 8082 (internal)
- PostgreSQL: 5432 (external), 5432 (internal)

## Troubleshooting 🔧

### Common Issues

#### 1. SSH Connection Failed
```
Error: Permission denied (publickey)
```
**Solution:**
- Verify `DEPLOY_KEY` secret contains valid SSH private key
- Ensure key format starts with `-----BEGIN OPENSSH PRIVATE KEY-----`
- Check that corresponding public key is in VM's `~/.ssh/authorized_keys`

#### 2. Docker Compose Failed
```
Error: docker-compose command not found
```
**Solution:**
- Install Docker Compose on VM
- Verify docker service is running: `sudo systemctl status docker`

#### 3. Port Already in Use
```
Error: Port 8080 is already in use
```
**Solution:**
- Stop existing containers: `docker-compose down`
- Check for other processes: `sudo lsof -i :8080`

#### 4. Database Connection Failed
```
Error: Connection to database failed
```
**Solution:**
- Check PostgreSQL container status: `docker-compose ps`
- Verify database initialization: `docker-compose logs postgres`
- Check .env file configuration

### Monitoring Commands

```bash
# Check deployment status on VM
ssh frazerfrax1@34.140.122.146 "cd ~/springmon-deployment && docker-compose ps"

# View service logs
ssh frazerfrax1@34.140.122.146 "cd ~/springmon-deployment && docker-compose logs"

# Monitor resource usage
ssh frazerfrax1@34.140.122.146 "docker stats"

# Check disk space
ssh frazerfrax1@34.140.122.146 "df -h"
```

## Security Considerations 🔒

1. **SSH Keys**: Use strong SSH keys (RSA 2048+ or Ed25519)
2. **JWT Secrets**: Use cryptographically secure random strings
3. **Database Passwords**: Use strong, unique passwords
4. **Network**: Consider firewall rules for port access
5. **Updates**: Keep VM and Docker images updated

## Rollback Procedure 🔄

In case of deployment issues:

1. **Stop current deployment:**
   ```bash
   ssh frazerfrax1@34.140.122.146 "cd ~/springmon-deployment && docker-compose down"
   ```

2. **Restore previous version:**
   ```bash
   # If you have backup directory
   ssh frazerfrax1@34.140.122.146 "cd ~/springmon-deployment-backup && docker-compose up -d"
   ```

3. **Revert GitHub repository:**
   ```bash
   git revert HEAD
   git push origin main
   ```

## Performance Monitoring 📊

### Key Metrics to Monitor
- Response time of health endpoints
- CPU and memory usage of containers
- Database connection pool status
- Disk space usage
- Network traffic

### Monitoring Commands
```bash
# Service response time
curl -w "@curl-format.txt" -o /dev/null -s http://34.140.122.146:8080/api/health

# Container resource usage
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Database connections
docker exec postgres psql -U springmon_user -d springmon -c "SELECT count(*) FROM pg_stat_activity;"
```

## Support & Maintenance 🛠️

For issues or questions:
1. Check GitHub Actions logs for deployment errors
2. Review VM logs using SSH access
3. Verify service health endpoints
4. Check Docker container status and logs

---

**Last Updated:** $(date)
**Version:** 1.0
**Environment:** Production VM 34.140.122.146
