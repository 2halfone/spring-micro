# 📝 User Service - Spiegazione Completa

## 🎯 Cos'è il User Service?

Il **User Service** è uno dei tre microservizi dell'architettura SpringMon che si occupa esclusivamente della **gestione degli utenti** (CRUD operations). È separato dall'Auth Service per seguire il principio di **separazione delle responsabilità**.

---

## 🔄 Separazione delle Responsabilità

### Auth Service vs User Service

```
┌─────────────────────────┐    ┌─────────────────────────┐
│      AUTH SERVICE       │    │      USER SERVICE       │
│     (Port 8082)         │    │     (Port 8083)         │
├─────────────────────────┤    ├─────────────────────────┤
│ ✅ Autenticazione       │    │ ✅ Gestione utenti      │
│ ✅ Login/Logout         │    │ ✅ CRUD operations      │
│ ✅ Token JWT            │    │ ✅ Ricerca utenti       │
│ ✅ Refresh Token        │    │ ✅ Profili utente       │
│ ✅ Validazione Token    │    │ ✅ Attivazione/Disatt.  │
│ ✅ Registrazione        │    │ ✅ Aggiornamento dati   │
└─────────────────────────┘    └─────────────────────────┘
```

---

## 🚀 Funzionalità del User Service

### 📋 API Endpoints Disponibili

#### **1. Gestione Utenti Base**
```http
GET    /api/users              # Lista tutti gli utenti
GET    /api/users/{id}         # Ottieni utente per ID
GET    /api/users/username/{username}  # Cerca per username
GET    /api/users/email/{email}        # Cerca per email
```

#### **2. Operazioni CRUD**
```http
POST   /api/users              # Crea nuovo utente
PUT    /api/users/{id}         # Aggiorna utente completo
DELETE /api/users/{id}         # Elimina utente
```

#### **3. Gestione Stato Utente**
```http
PATCH  /api/users/{id}/activate    # Attiva utente
PATCH  /api/users/{id}/deactivate  # Disattiva utente
GET    /api/users?activeOnly=true  # Solo utenti attivi
```

#### **4. Ricerca e Filtri**
```http
GET    /api/users/search?name=Mario  # Ricerca per nome
```

---

## 🏗️ Architettura del User Service

### 📂 Struttura del Codice
```
user-service/
├── controller/
│   └── UserController.java     # API REST endpoints
├── service/
│   └── UserService.java        # Business logic
├── repository/
│   └── UserRepository.java     # Data access
├── entity/
│   └── User.java              # Entity JPA
└── UserServiceApplication.java # Main class
```

### 🔗 Integrazione con Auth Service

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant AuthService
    participant UserService
    participant Database

    Client->>Gateway: GET /api/users (con JWT token)
    Gateway->>AuthService: Valida JWT token
    AuthService-->>Gateway: Token valido ✅
    Gateway->>UserService: Inoltra richiesta
    UserService->>Database: Query utenti
    Database-->>UserService: Risultati
    UserService-->>Gateway: Lista utenti
    Gateway-->>Client: Risposta finale
```

---

## 🛡️ Sicurezza del User Service

### 🔐 Protezione delle Route
- **Tutte** le operazioni del User Service sono **protette**
- Richiede **JWT token valido** tramite Gateway
- Solo utenti autenticati possono accedere

### 🚧 Flusso di Sicurezza
1. Client fa richiesta al Gateway (port 8080)
2. Gateway valida il JWT token con Auth Service
3. Se token valido → inoltra richiesta al User Service
4. Se token invalido → blocca richiesta (401 Unauthorized)

---

## 📊 Esempi di Utilizzo

### 1. **Ottenere Lista Utenti**
```bash
# Richiesta al Gateway (con autenticazione)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8080/api/users
```

### 2. **Cercare Utente per Username**
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8080/api/users/username/mario.rossi
```

### 3. **Aggiornare Profilo Utente**
```bash
curl -X PUT \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"firstName":"Mario","lastName":"Rossi","email":"mario.rossi@email.com"}' \
     http://localhost:8080/api/users/1
```

### 4. **Disattivare Utente**
```bash
curl -X PATCH \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:8080/api/users/1/deactivate
```

---

## 🎯 Vantaggi della Separazione

### ✅ **Scalabilità Indipendente**
- User Service può essere scalato separatamente
- Più istanze per gestire carichi elevati di lettura
- Ottimizzazioni specifiche per operazioni CRUD

### ✅ **Manutenibilità**
- Codice più pulito e focalizzato
- Team diversi possono lavorare sui servizi
- Deploy indipendenti

### ✅ **Sicurezza Granulare**
- Permessi specifici per operazioni utente
- Separazione logica delle responsabilità
- Audit trail dedicato

### ✅ **Resilienza**
- Se User Service è down, l'autenticazione funziona ancora
- Fallback e circuit breaker possibili
- Monitoring separato

---

## 📈 Casi d'Uso Tipici

### **Amministrazione Sistema**
- Dashboard amministratore per gestire utenti
- Bulk operations (attivazione/disattivazione)
- Reportistica utenti

### **Profilo Utente**
- Aggiornamento informazioni personali
- Gestione preferenze
- Visualizzazione storico attività

### **Ricerca e Filtri**
- Directory aziendale
- Ricerca colleghi/collaboratori
- Filtri avanzati per ruoli/dipartimenti

---

## 🔄 Interazione con Altri Servizi

```
┌─────────────────┐
│   Gateway       │ ← Entry point per tutte le richieste
│   (Port 8080)   │
└─────────┬───────┘
          │
          ├─→ Auth Service (8082)    ← Validazione JWT
          │
          └─→ User Service (8083)    ← Gestione utenti
                     │
                     ▼
               ┌─────────────┐
               │ PostgreSQL  │ ← Database condiviso
               │ (Port 5432) │
               └─────────────┘
```

---

## 🎪 Esempio Completo

### Scenario: "Visualizzare profilo utente"

1. **Client** invia richiesta al Gateway:
   ```http
   GET /api/users/123
   Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
   ```

2. **Gateway** valida token con Auth Service:
   ```http
   POST /api/auth/validate?token=eyJhbGciOiJIUzI1NiIs...
   ```

3. **Auth Service** conferma validità token

4. **Gateway** inoltra richiesta al User Service:
   ```http
   GET /api/users/123
   ```

5. **User Service** recupera dati dal database

6. **Risposta** completa ritorna al client:
   ```json
   {
     "id": 123,
     "username": "mario.rossi",
     "email": "mario.rossi@company.com",
     "firstName": "Mario",
     "lastName": "Rossi",
     "isActive": true,
     "createdAt": "2025-01-01T10:00:00",
     "lastLogin": "2025-06-04T14:30:00"
   }
   ```

---

## 💡 In Sintesi

Il **User Service** è il microservizio dedicato alla **gestione completa degli utenti** nell'architettura SpringMon:

- 🎯 **Responsabilità**: CRUD operations sugli utenti
- 🔐 **Sicurezza**: Protetto da JWT tramite Gateway  
- 🚀 **Scalabilità**: Indipendente dagli altri servizi
- 🛠️ **Funzionalità**: Ricerca, filtri, gestione stato utenti
- 📊 **Integrazione**: Lavora insieme ad Auth Service per sicurezza completa

È una **separazione logica e tecnica** che rende l'architettura più robusta, scalabile e manutenibile!
