# 🚀 QUICK START GUIDE - VM TESTING

## PREREQUISITI
1. VM con SpringMon deployato
2. PowerShell 5.0+ (o PowerShell Core)
3. IP della VM accessibile

## ESECUZIONE RAPIDA

### Metodo 1: Test Completo Automatico
```powershell
# Copiare lo script sulla macchina di test
.\post-deploy-vm-test-suite.ps1 -VMIp "192.168.1.100"
```

### Metodo 2: Test con Parametri Personalizzati
```powershell
.\post-deploy-vm-test-suite.ps1 -VMIp "192.168.1.100" -TestUser "myuser" -TestPassword "mypass" -VerboseOutput $true
```

### Metodo 3: Test Rapido di Verifica
```powershell
# Solo health check e connectivity
$VM_IP = "192.168.1.100"
curl "http://$VM_IP:8080/actuator/health"
curl "http://$VM_IP:8081/actuator/health"  
curl "http://$VM_IP:8083/api/health"
```

## INTERPRETAZIONE RISULTATI

### ✅ SUCCESS (Success Rate >= 80%)
- **Significato**: Spring Security implementato correttamente
- **Azione**: Procedere con Priority 2 tasks

### ⚠️ PARTIAL_SUCCESS (Success Rate 60-79%)
- **Significato**: Implementazione parzialmente funzionante
- **Azione**: Rivedere raccomandazioni nel report

### ❌ FAILURE (Success Rate < 60%)
- **Significato**: Problemi critici nella implementazione
- **Azione**: Verificare deploy e configurazioni

## OUTPUT FILES

- `vm_security_test_report_YYYYMMDD_HHMMSS.json`: Report dettagliato
- Console output: Risultati in tempo reale

## TROUBLESHOOTING COMUNE

### "VM non raggiungibile"
```powershell
# Verificare connectivity
Test-NetConnection -ComputerName "192.168.1.100" -Port 8080
```

### "Servizi non rispondono"
```powershell
# Verificare status servizi sulla VM
docker ps
docker logs gateway-service
```

### "JWT tests falliscono"
- Verificare che Auth Service sia connesso al database
- Controllare JWT secret consistency tra servizi

## NEXT STEPS POST-TEST

### Se SUCCESS:
1. Commit delle implementazioni Security
2. Procedere con **Priority 2: JWT Security Enhancement**
3. Aggiornare documentazione di sicurezza

### Se FAILURE:
1. Analizzare report dettagliato
2. Verificare logs dei servizi
3. Re-test delle configurazioni localmente
4. Ripetere deploy se necessario

---

**IMPORTANTE**: Questo test deve essere l'ultimo step di verifica prima di considerare completata la Priority 1 - Spring Security Implementation.
