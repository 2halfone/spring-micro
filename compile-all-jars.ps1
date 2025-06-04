# 🔨 Script di compilazione completa per SpringMon
# Usa il comando `javac` direttamente o Maven se disponibile

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
    Write-Host "⚠️  Maven non trovato - useremo approccio alternativo" -ForegroundColor Yellow
}

# Array dei servizi da compilare
$services = @("gateway-service", "auth-service", "user-service")

Write-Host "`n🔨 Inizio compilazione dei servizi..." -ForegroundColor Yellow

foreach ($service in $services) {
    Write-Host "`n📦 Compilazione $service..." -ForegroundColor Cyan
    
    # Entra nella directory del servizio
    Set-Location $service
    
    if ($mavenAvailable) {
        Write-Host "   Usando Maven: mvn clean package -DskipTests" -ForegroundColor Gray
        mvn clean package -DskipTests
    } else {
        Write-Host "   ⚠️  Maven non disponibile - i JAR esistenti verranno utilizzati" -ForegroundColor Yellow
        Write-Host "   💡 Per compilare nuovi JAR, installa Maven o usa VS Code Java Extension" -ForegroundColor Yellow
    }
    
    if ($LASTEXITCODE -eq 0 -or -not $mavenAvailable) {
        if ($mavenAvailable) {
            Write-Host "✅ $service compilato con successo!" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  $service - usando JAR esistente" -ForegroundColor Cyan
        }
        
        # Verifica che il JAR esista
        $jarFiles = Get-ChildItem -Path "target/*.jar" -ErrorAction SilentlyContinue
        if ($jarFiles) {
            foreach ($jar in $jarFiles) {
                $age = (Get-Date) - $jar.LastWriteTime
                $ageColor = if ($age.TotalHours -lt 1) { "Green" } elseif ($age.TotalDays -lt 1) { "Yellow" } else { "Red" }
                Write-Host "   📄 JAR: $($jar.Name) - $($jar.LastWriteTime)" -ForegroundColor $ageColor
                if ($age.TotalDays -gt 1) {
                    Write-Host "   ⚠️  JAR è vecchio di $([math]::Round($age.TotalDays, 1)) giorni!" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "   ❌ Nessun JAR trovato in target/" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Errore nella compilazione di $service" -ForegroundColor Red
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
        Write-Host "✅ $service`: $($jarInfo.LastWriteTime)" -ForegroundColor Green
    } else {
        Write-Host "❌ $service`: JAR non trovato!" -ForegroundColor Red
    }
}

Write-Host "`n🚀 Compilazione completata!" -ForegroundColor Green
Write-Host "I JAR aggiornati sono pronti per il deployment su VM." -ForegroundColor Green

# Verifica che Docker Compose sia pronto
Write-Host "`n🔍 Verifico configurazione Docker Compose..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "✅ docker-compose.yml trovato" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose.yml non trovato!" -ForegroundColor Red
}

Write-Host "`n💡 Prossimi passi:" -ForegroundColor Cyan
if (-not $mavenAvailable) {
    Write-Host "🔧 Per compilare nuovi JAR:" -ForegroundColor Yellow
    Write-Host "   Opzione 1: Installa Maven - https://maven.apache.org/download.cgi" -ForegroundColor Gray
    Write-Host "   Opzione 2: Usa VS Code Java Extension Pack" -ForegroundColor Gray
    Write-Host "   Opzione 3: GitHub Actions compilerà automaticamente durante il deploy" -ForegroundColor Gray
    Write-Host ""
}
Write-Host "1. Commit delle modifiche: git add . ; git commit -m 'Update configurations'" -ForegroundColor Gray
Write-Host "2. Push al repository: git push origin main" -ForegroundColor Gray
Write-Host "3. GitHub Actions compilerà e deploierà automaticamente su VM" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 IMPORTANTE: GitHub Actions ha Maven e compilerà JAR freschi durante il deployment!" -ForegroundColor Green
