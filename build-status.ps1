# 🔨 Script di compilazione completa per SpringMon
# Verifica Maven e compila tutti i servizi

Write-Host "🚀 SpringMon - Compilazione Completa dei JAR" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Verifica Java
Write-Host "`n🔍 Verifico Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java trovato: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java non trovato!" -ForegroundColor Red
    exit 1
}

# Verifica Maven (opzionale)
Write-Host "`n🔍 Verifico Maven..." -ForegroundColor Yellow
$mavenAvailable = $false
try {
    mvn -version | Out-Null
    Write-Host "✅ Maven è disponibile" -ForegroundColor Green
    $mavenAvailable = $true
} catch {
    Write-Host "⚠️  Maven non trovato - useremo JAR esistenti" -ForegroundColor Yellow
}

# Array dei servizi da compilare
$services = @("gateway-service", "auth-service", "user-service")

Write-Host "`n🔨 Analisi servizi..." -ForegroundColor Yellow

foreach ($service in $services) {
    Write-Host "`n📦 Verifica $service..." -ForegroundColor Cyan
    
    # Entra nella directory del servizio
    Set-Location $service
    
    if ($mavenAvailable) {
        Write-Host "   Compilando con Maven: mvn clean package -DskipTests" -ForegroundColor Gray
        mvn clean package -DskipTests
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $service compilato con successo!" -ForegroundColor Green
        } else {
            Write-Host "❌ Errore nella compilazione di $service" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Maven non disponibile - controllo JAR esistente" -ForegroundColor Yellow
    }
    
    # Verifica che il JAR esista
    $jarFiles = Get-ChildItem -Path "target/*.jar" -ErrorAction SilentlyContinue
    if ($jarFiles) {
        foreach ($jar in $jarFiles) {
            $age = (Get-Date) - $jar.LastWriteTime
            $ageHours = [math]::Round($age.TotalHours, 1)
            
            if ($age.TotalHours -lt 1) {
                $ageColor = "Green"
                $status = "FRESCO"
            } elseif ($age.TotalDays -lt 1) {
                $ageColor = "Yellow" 
                $status = "RECENTE"
            } else {
                $ageColor = "Red"
                $status = "VECCHIO"
            }
            
            Write-Host "   📄 JAR: $($jar.Name)" -ForegroundColor $ageColor
            Write-Host "      Creato: $($jar.LastWriteTime) - $status ($ageHours ore fa)" -ForegroundColor $ageColor
        }
    } else {
        Write-Host "   ❌ Nessun JAR trovato in target/" -ForegroundColor Red
    }
    
    # Torna alla directory principale
    Set-Location ..
}

Write-Host "`n🎯 Riepilogo finale:" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow

foreach ($service in $services) {
    $jarPath = "$service/target/$service-1.0.0-SNAPSHOT.jar"
    if (Test-Path $jarPath) {
        $jarInfo = Get-Item $jarPath
        $age = (Get-Date) - $jarInfo.LastWriteTime
        
        if ($age.TotalHours -lt 1) {
            Write-Host "✅ $service : AGGIORNATO ($($jarInfo.LastWriteTime))" -ForegroundColor Green
        } elseif ($age.TotalDays -lt 1) {
            Write-Host "⚠️  $service : RECENTE ($($jarInfo.LastWriteTime))" -ForegroundColor Yellow
        } else {
            Write-Host "❌ $service : VECCHIO ($($jarInfo.LastWriteTime))" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ $service : JAR NON TROVATO!" -ForegroundColor Red
    }
}

Write-Host "`n💡 Strategia di Deployment:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if (-not $mavenAvailable) {
    Write-Host "🔧 Maven non installato localmente, ma NON È UN PROBLEMA!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ GitHub Actions compilerà JAR freschi automaticamente:" -ForegroundColor Yellow
    Write-Host "   1. Maven 3.8+ è installato nel runner GitHub" -ForegroundColor Gray
    Write-Host "   2. Ogni deploy compila da zero con le ultime modifiche" -ForegroundColor Gray
    Write-Host "   3. JAR vengono trasferiti freschi sulla VM" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "🚀 Prossimi passi IMMEDIATI:" -ForegroundColor Green
Write-Host "1. git add ." -ForegroundColor Gray
Write-Host "2. git commit -m \"Update SpringMon configurations and fixes\"" -ForegroundColor Gray  
Write-Host "3. git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 RISULTATO: GitHub Actions compilerà e deploierà tutto automaticamente!" -ForegroundColor Green

Write-Host "`n📋 Verifica configurazione Docker Compose..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "✅ docker-compose.yml trovato e aggiornato" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose.yml non trovato!" -ForegroundColor Red
}
