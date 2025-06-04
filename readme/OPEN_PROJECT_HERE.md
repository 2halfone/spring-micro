# 🚀 COME APRIRE IL PROGETTO SpringMon Microservices

## 📁 **DIRECTORY DI LAVORO CORRETTA**

**IMPORTANTE:** Apri il progetto direttamente da questa directory:

```
spring-boot-template\springmon-microservices\
```

❌ **NON aprire da:** `spring-boot-template\` (directory parent)  
✅ **APRI da:** `spring-boot-template\springmon-microservices\` (questa directory)

## 🔧 **CONFIGURAZIONE IDE**

### **IntelliJ IDEA / VS Code**
1. **File → Open Folder/Project**
2. Naviga a: `spring-boot-template\springmon-microservices\`
3. Seleziona questa directory come root del progetto
4. L'IDE rileverà automaticamente i 3 moduli Maven:
   - `auth-service`
   - `user-service`  
   - `gateway-service`

### **Eclipse/STS**
1. **File → Import → Existing Maven Projects**
2. Root Directory: `spring-boot-template\springmon-microservices\`
3. Seleziona tutti i progetti trovati

## 📊 **STRUTTURA PROGETTO**

```
springmon-microservices/          ← APRI DA QUI!
├── 📄 pom.xml                   ← Parent POM
├── 📄 README.md                 ← Documentazione completa
├── 📄 docker-compose.yml        ← Orchestrazione container
│
├── 🔐 auth-service/             ← Port 8082
│   ├── 📄 pom.xml
│   └── 📁 src/main/java/com/springmon/auth/
│
├── 👥 user-service/             ← Port 8081  
│   ├── 📄 pom.xml
│   └── 📁 src/main/java/com/springmon/user/
│
└── 🌐 gateway-service/          ← Port 8080
    ├── 📄 pom.xml
    └── 📁 src/main/java/com/springmon/gateway/
```

## 🚀 **AVVIO RAPIDO**

### **Opzione 1: Maven (Sviluppo)**
```bash
# Terminal 1
cd auth-service
mvn spring-boot:run

# Terminal 2  
cd user-service
mvn spring-boot:run

# Terminal 3
cd gateway-service
mvn spring-boot:run
```

### **Opzione 2: Docker (Produzione)**
```bash
# Dalla directory springmon-microservices/
docker-compose up -d
```

## 🔧 **PREREQUISITI**

Assicurati di avere:
- ☕ **Java 17+**
- 🔨 **Maven 3.6+**
- 🐘 **PostgreSQL 12+** (per database)
- 🐳 **Docker** (opzionale, per containerizzazione)

## 🌐 **URL DEI SERVIZI**

Dopo l'avvio:
- **Gateway API**: http://localhost:8080
- **Auth Service**: http://localhost:8082  
- **User Service**: http://localhost:8081

## 🔑 **TEST RAPIDO**

```bash
# Registrazione utente
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"password123","firstName":"Test","lastName":"User"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \  
  -d '{"username":"test","password":"password123"}'
```

## 📝 **NOTE IMPORTANTI**

1. **Directory di lavoro:** Sempre `springmon-microservices/`
2. **Git repository:** Inizializzato in questa directory  
3. **Parent POM:** Gestisce tutti i moduli da qui
4. **Docker:** Configurato per questa struttura

---

**🎯 Apri il progetto da `springmon-microservices/` e sei pronto per sviluppare!**
