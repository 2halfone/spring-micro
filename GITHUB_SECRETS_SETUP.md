# 🔧 Configurazione GitHub Secrets per Deploy SpringMon

## ❌ Problema Identificato: Permission denied (publickey)

L'errore SSH è causato da una configurazione incorretta dei GitHub Secrets. Segui questa guida per risolverlo.

## 📋 Secrets Richiesti

Vai su **GitHub Repository → Settings → Secrets and variables → Actions** e configura:

### 1. `DEPLOY_KEY` (SSH Private Key)
```
-----BEGIN OPENSSH PRIVATE KEY-----
[La tua chiave SSH privata qui]
-----END OPENSSH PRIVATE KEY-----
```

**⚠️ IMPORTANTE:**
- Usa il formato OpenSSH (non PuTTY .ppk)
- Assicurati che NON ci siano spazi extra o caratteri Windows
- La chiave deve corrispondere alla chiave pubblica sulla VM

### 2. `DEPLOY_HOST`
```
34.140.122.146
```

### 3. `DEPLOY_USER`
```
frazerfrax1
```

## 🔑 Come Generare/Verificare la Chiave SSH

### Su Windows (PowerShell):
```powershell
# Genera nuova chiave SSH
ssh-keygen -t rsa -b 4096 -C "deploy@springmon"

# Visualizza chiave pubblica
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub

# Visualizza chiave privata (da copiare in DEPLOY_KEY)
Get-Content $env:USERPROFILE\.ssh\id_rsa
```

### Su VM (34.140.122.146):
```bash
# Aggiungi la chiave pubblica alla VM
echo "TUA_CHIAVE_PUBBLICA_QUI" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

## 🧪 Test SSH Locale

Prima di usare la pipeline, testa la connessione SSH:

```powershell
# Test connessione SSH
ssh -i path\to\private\key frazerfrax1@34.140.122.146 "echo 'SSH Test OK'"
```

## 🔍 Debugging SSH nella Pipeline

Il workflow ora include:

1. **Validazione formato chiave**: `ssh-keygen -l -f key.pem`
2. **Rimozione caratteri Windows**: `tr -d '\r'`
3. **Test connessione verbose**: `ssh -v`
4. **Timeout configurabile**: `ConnectTimeout=30`

## 📊 Monitoraggio Pipeline

1. Vai su **GitHub → Actions**
2. Seleziona l'ultimo workflow run
3. Verifica i log del job "🔑 Setup SSH Key & Test Connection"

## ✅ Checklist Risoluzione

- [ ] Chiave SSH generata con formato OpenSSH
- [ ] Chiave pubblica aggiunta alla VM (`~/.ssh/authorized_keys`)
- [ ] Chiave privata copiata in `DEPLOY_KEY` secret (senza spazi extra)
- [ ] `DEPLOY_HOST` = `34.140.122.146`
- [ ] `DEPLOY_USER` = `frazerfrax1` 
- [ ] Test SSH locale funzionante
- [ ] Pipeline attivata con nuovo commit

## 🚀 Prossimi Passi

Dopo aver configurato i secrets:

1. Fai un nuovo commit per attivare la pipeline
2. Monitora i log della pipeline su GitHub Actions
3. Verifica il deploy su http://34.140.122.146:8080/api/health

## 🆘 Risoluzione Problemi Comuni

### "Invalid SSH key format"
- Verifica che la chiave inizi con `-----BEGIN OPENSSH PRIVATE KEY-----`
- Non usare chiavi in formato PuTTY (.ppk)

### "Connection refused"
- Verifica che la VM sia attiva
- Controlla che SSH sia abilitato sulla porta 22

### "Permission denied"
- Verifica che la chiave pubblica sia in `~/.ssh/authorized_keys`
- Controlla i permessi: `chmod 600 ~/.ssh/authorized_keys`
