# SpringMon Microservices Architecture

## Overview
Complete Spring Boot microservices architecture with authentication, user management, and API gateway. This system provides a robust foundation for scalable applications with proper security, service communication, and data management.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│  Gateway Service│───▶│   Auth Service   │    │  User Service   │
│    (Port 8080)  │    │   (Port 8082)    │    │   (Port 8081)   │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                        │                        │
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│   JWT Security  │    │ PostgreSQL DB    │    │ PostgreSQL DB   │
│   Validation    │    │ (Auth Data)      │    │ (User Data)     │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Services

### 1. Auth Service (Port 8082)
**Purpose**: User authentication and JWT token management

**Features**:
- User registration with role assignment
- User login with JWT token generation  
- Password encryption with BCrypt
- JWT token validation endpoint
- Role-based access control
- Refresh token support

**Endpoints**:
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/validate` - JWT token validation

### 2. User Service (Port 8081)  
**Purpose**: User data management and CRUD operations

**Features**:
- Complete user CRUD operations
- User search and filtering
- User activation/deactivation
- Email and username uniqueness validation
- User profile management

**Endpoints**:
- `GET /api/users` - Get all users (with active filter option)
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/username/{username}` - Get user by username
- `GET /api/users/email/{email}` - Get user by email
- `GET /api/users/search?name={name}` - Search users by name
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `PATCH /api/users/{id}/activate` - Activate user
- `PATCH /api/users/{id}/deactivate` - Deactivate user

### 3. Gateway Service (Port 8080)
**Purpose**: Single entry point and request routing

**Features**:
- JWT token validation for protected routes
- Request routing to appropriate services
- Cross-service communication
- Security filter implementation
- Centralized authentication handling

**Key Components**:
- `JwtValidationService` - Local JWT validation
- `AuthProxyService` - Auth service communication
- `SecurityConfig` - Security configuration
- `GatewayController` - Route handling

## Technology Stack

### Core Technologies
- **Java 17** - Programming language
- **Spring Boot 3.2.1** - Framework
- **Spring Security** - Authentication & authorization
- **Spring Data JPA** - Data access layer
- **PostgreSQL** - Primary database
- **H2** - Testing database

### JWT & Security
- **JJWT 0.12.3** - JWT implementation
- **BCrypt** - Password encryption
- **Bearer Token** - Authentication method

### Build & Deployment
- **Maven** - Build tool
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration

## Project Structure

```
springmon-microservices/
├── pom.xml                    # Parent POM
├── docker-compose.yml         # Docker orchestration
├── test-compile.ps1          # Testing script
│
├── auth-service/             # Authentication Service
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/springmon/auth/
│       ├── AuthServiceApplication.java
│       ├── controller/
│       │   └── AuthController.java
│       ├── entity/
│       │   ├── User.java
│       │   ├── Role.java
│       │   └── RefreshToken.java
│       ├── repository/
│       │   ├── UserRepository.java
│       │   ├── RoleRepository.java
│       │   └── RefreshTokenRepository.java
│       ├── service/
│       │   └── AuthService.java
│       ├── security/
│       │   ├── JwtTokenProvider.java
│       │   ├── JwtAuthenticationEntryPoint.java
│       │   └── SecurityConfig.java
│       └── dto/
│           ├── LoginRequest.java
│           ├── RegisterRequest.java
│           └── JwtResponse.java
│
├── user-service/             # User Management Service
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/java/com/springmon/user/
│       ├── UserServiceApplication.java
│       ├── controller/
│       │   └── UserController.java
│       ├── entity/
│       │   └── User.java
│       ├── repository/
│       │   └── UserRepository.java
│       └── service/
│           └── UserService.java
│
└── gateway-service/          # API Gateway Service
    ├── pom.xml
    ├── Dockerfile
    └── src/main/java/com/springmon/gateway/
        ├── GatewayServiceApplication.java
        ├── controller/
        │   └── GatewayController.java
        ├── service/
        │   ├── JwtValidationService.java
        │   └── AuthProxyService.java
        └── config/
            └── SecurityConfig.java
```

## Getting Started

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL 12+
- Docker (optional)

### Database Setup
1. Create PostgreSQL databases:
```sql
CREATE DATABASE springmon_auth;
CREATE DATABASE springmon_user;
```

2. Create database users:
```sql
CREATE USER springmon_user WITH PASSWORD 'springmon_password';
GRANT ALL PRIVILEGES ON DATABASE springmon_auth TO springmon_user;
GRANT ALL PRIVILEGES ON DATABASE springmon_user TO springmon_user;
```

### Running Services

#### Option 1: Maven (Development)
```bash
# Terminal 1 - Auth Service
cd auth-service
mvn spring-boot:run

# Terminal 2 - User Service  
cd user-service
mvn spring-boot:run

# Terminal 3 - Gateway Service
cd gateway-service
mvn spring-boot:run
```

#### Option 2: Docker Compose (Production)
```bash
docker-compose up -d
```

### Testing the Services

#### 1. Register a User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "firstName": "Test",
    "lastName": "User"
  }'
```

#### 2. Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

#### 3. Use JWT Token
```bash
# Use the token from login response
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Configuration

### Auth Service (application.properties)
```properties
server.port=8082
spring.datasource.url=jdbc:postgresql://localhost:5432/springmon_auth
jwt.secret=springmon_jwt_secret_key_2024_very_secure_random_string
jwt.expiration=3600000
```

### User Service (application.properties)  
```properties
server.port=8081
spring.datasource.url=jdbc:postgresql://localhost:5432/springmon_user
```

### Gateway Service (application.properties)
```properties
server.port=8080
auth.service.url=http://localhost:8082
user.service.url=http://localhost:8081
```

## Security Features

### JWT Implementation
- **Algorithm**: HMAC-SHA256
- **Expiration**: 1 hour (configurable)
- **Claims**: username, roles, expiration
- **Validation**: Signature, expiration, format

### Password Security
- **Encryption**: BCrypt with salt
- **Minimum Requirements**: 6+ characters
- **Storage**: Never stored in plain text

### API Security
- **Authentication**: Bearer token required
- **Authorization**: Role-based access control
- **CORS**: Configurable cross-origin support
- **Validation**: Input validation on all endpoints

## Monitoring & Health Checks

### Actuator Endpoints
All services expose health check endpoints:
- `GET /actuator/health` - Service health status
- `GET /actuator/info` - Service information

### Service URLs
- **Auth Service**: http://localhost:8082/actuator/health
- **User Service**: http://localhost:8081/actuator/health  
- **Gateway Service**: http://localhost:8080/actuator/health

## Development

### Adding New Services
1. Create new Maven module
2. Add to parent pom.xml modules section
3. Follow the same package structure pattern
4. Add service configuration to Gateway Service
5. Update Docker Compose if needed

### Testing
Each service includes:
- Unit tests with JUnit 5
- Integration tests with TestContainers
- MockMvc for controller testing
- H2 in-memory database for testing

### Code Quality
- **Validation**: Jakarta Bean Validation
- **Exception Handling**: Global exception handlers
- **Logging**: SLF4J with Logback
- **Documentation**: Comprehensive JavaDoc

## Deployment

### Docker Images
Each service has its own Dockerfile for containerization.

### Environment Variables
Configure services using environment variables:
```bash
export JWT_SECRET=your_secret_key
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=springmon_auth
export DB_USER=springmon_user
export DB_PASSWORD=springmon_password
```

## Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure ports 8080, 8081, 8082 are available
2. **Database connection**: Verify PostgreSQL is running and credentials are correct
3. **JWT errors**: Check secret key consistency across services
4. **CORS issues**: Configure allowed origins in Gateway Service

### Logs
Enable debug logging for troubleshooting:
```properties
logging.level.com.springmon=DEBUG
```

## Contributing

1. Follow existing code structure and patterns
2. Add appropriate tests for new features
3. Update documentation for API changes
4. Use consistent naming conventions
5. Implement proper error handling

---

**SpringMon Microservices** - A complete, production-ready microservices architecture with Spring Boot 3.2.1 and Java 17.
