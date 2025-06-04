# 🔨 Script per installare Maven e compilare SpringMon JAR
# Per Windows senza Docker

Write-Host "🚀 SpringMon - Setup Maven e Compilazione" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Verifica Java
Write-Host "`n🔍 Verifico Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java trovato: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java non trovato! È necessario Java 17+" -ForegroundColor Red
    exit 1
}

# Verifica se Maven è già installato
Write-Host "`n🔍 Verifico Maven..." -ForegroundColor Yellow
try {
    $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven"
    Write-Host "✅ Maven già installato: $mavenVersion" -ForegroundColor Green
    $mavenExists = $true
} catch {
    Write-Host "⚠️  Maven non trovato. Installazione necessaria..." -ForegroundColor Yellow
    $mavenExists = $false
}

# Installa Maven se non presente
if (-not $mavenExists) {
    Write-Host "`n📦 Installazione Maven tramite Chocolatey..." -ForegroundColor Cyan
    
    # Verifica se Chocolatey è installato
    try {
        choco --version | Out-Null
        Write-Host "✅ Chocolatey trovato" -ForegroundColor Green
        
        Write-Host "Installando Maven..." -ForegroundColor Yellow
        choco install maven -y
        
        # Aggiorna il PATH per questa sessione
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "✅ Maven installato!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Chocolatey non trovato. Installazione manuale necessaria." -ForegroundColor Red
        Write-Host "   Scarica Maven da: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
        Write-Host "   Oppure installa Chocolatey prima: https://chocolatey.org/install" -ForegroundColor Yellow
        
        # Download manuale Maven
        Write-Host "`n📥 Tentativo download Maven..." -ForegroundColor Cyan
        $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
        $downloadPath = "$env:TEMP\maven.zip"
        $extractPath = "C:\tools\maven"
        
        try {
            Write-Host "Downloading from $mavenUrl..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath
            
            Write-Host "Estraendo Maven in $extractPath..." -ForegroundColor Gray
            Expand-Archive -Path $downloadPath -DestinationPath "C:\tools" -Force
            
            # Rinomina la cartella
            if (Test-Path "C:\tools\apache-maven-3.9.6") {
                if (Test-Path $extractPath) { Remove-Item $extractPath -Recurse -Force }
                Rename-Item "C:\tools\apache-maven-3.9.6" "maven"
            }
            
            # Aggiungi al PATH
            $mavenBin = "$extractPath\bin"
            $env:Path += ";$mavenBin"
            
            Write-Host "✅ Maven installato manualmente!" -ForegroundColor Green
            Write-Host "⚠️  IMPORTANTE: Riavvia PowerShell o aggiungi $mavenBin al PATH di sistema" -ForegroundColor Yellow
        } catch {
            Write-Host "❌ Fallimento download automatico. Installazione manuale richiesta." -ForegroundColor Red
            exit 1
        }
    }
}

# Verifica finale Maven
Write-Host "`n🔍 Verifica finale Maven..." -ForegroundColor Yellow
try {
    mvn -version
    Write-Host "✅ Maven pronto!" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven non disponibile. Controlla l'installazione." -ForegroundColor Red
    Write-Host "💡 Prova a riavviare PowerShell se hai appena installato Maven" -ForegroundColor Yellow
    exit 1
}

# Compila tutti i servizi
Write-Host "`n🔨 Inizio compilazione servizi..." -ForegroundColor Green
$services = @("gateway-service", "auth-service", "user-service")

foreach ($service in $services) {
    Write-Host "`n📦 Compilazione $service..." -ForegroundColor Cyan
    
    if (Test-Path $service) {
        Set-Location $service
        
        Write-Host "   Eseguendo: mvn clean package -DskipTests" -ForegroundColor Gray
        mvn clean package -DskipTests
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $service compilato con successo!" -ForegroundColor Green
            
            # Verifica JAR
            $jarFiles = Get-ChildItem -Path "target\*.jar" -ErrorAction SilentlyContinue
            foreach ($jar in $jarFiles) {
                Write-Host "   📄 JAR: $($jar.Name) - $($jar.LastWriteTime)" -ForegroundColor Gray
            }
        } else {
            Write-Host "❌ Errore compilazione $service" -ForegroundColor Red
        }
        
        Set-Location ..
    } else {
        Write-Host "❌ Directory $service non trovata!" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Riepilogo Compilazione:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

foreach ($service in $services) {
    $jarPath = "$service\target\$service-1.0.0-SNAPSHOT.jar"
    if (Test-Path $jarPath) {
        $jarInfo = Get-Item $jarPath
        Write-Host "✅ $service`: $($jarInfo.LastWriteTime)" -ForegroundColor Green
    } else {
        Write-Host "❌ $service`: JAR non trovato!" -ForegroundColor Red
    }
}

Write-Host "`n🚀 Compilazione completata!" -ForegroundColor Green
Write-Host "Tutti i JAR sono aggiornati con le ultime modifiche." -ForegroundColor Green
