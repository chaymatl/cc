# dev.ps1 — Script de developpement EcoRewind
# Usage : .\dev.ps1 [commande]
# ================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("start","stop","restart","logs","build","migrate","status","clean","apk","help","")]
    [string]$Command = "help"
)

$BackendDir = Join-Path $PSScriptRoot "backend"
$ErrorActionPreference = "Stop"

function Write-Header($text) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
}

function Assert-Docker {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERREUR] Docker n'est pas en cours d'execution." -ForegroundColor Red
        exit 1
    }
}

function Assert-Env {
    $envFile = Join-Path $BackendDir ".env"
    if (-not (Test-Path $envFile)) {
        Write-Host "[ATTENTION] .env absent. Copie depuis .env.example..." -ForegroundColor Yellow
        Copy-Item (Join-Path $BackendDir ".env.example") $envFile
        Write-Host "Editez backend\.env avec vos vraies valeurs." -ForegroundColor Yellow
        exit 1
    }
}

switch ($Command) {

    "start" {
        Write-Header "Demarrage EcoRewind Backend"
        Assert-Docker
        Assert-Env
        Set-Location $BackendDir
        docker compose --profile standalone up --build -d
        Write-Host ""
        Write-Host "Backend disponible sur : http://localhost:8000" -ForegroundColor Green
        Write-Host "Docs API               : http://localhost:8000/docs" -ForegroundColor Green
        Write-Host "Logs                   : .\dev.ps1 logs" -ForegroundColor Gray
    }

    "stop" {
        Write-Header "Arret des conteneurs"
        Set-Location $BackendDir
        docker compose down
        Write-Host "Conteneurs arretes." -ForegroundColor Green
    }

    "restart" {
        Write-Header "Redemarrage"
        Set-Location $BackendDir
        docker compose down
        docker compose --profile standalone up --build -d
        Write-Host "Redemarrage termine." -ForegroundColor Green
    }

    "logs" {
        Write-Header "Logs en temps reel (Ctrl+C pour quitter)"
        Set-Location $BackendDir
        docker compose logs -f api
    }

    "build" {
        Write-Header "Build des images Docker"
        Assert-Docker
        Set-Location $BackendDir
        docker compose build --no-cache api
        Write-Host "Build termine." -ForegroundColor Green
    }

    "migrate" {
        Write-Header "Migrations Alembic"
        Set-Location $BackendDir
        docker compose exec api alembic upgrade head
        Write-Host "Migrations appliquees." -ForegroundColor Green
    }

    "status" {
        Write-Header "Etat des conteneurs"
        Set-Location $BackendDir
        docker compose ps
    }

    "clean" {
        Write-Header "Nettoyage complet (supprime les volumes !)"
        $confirm = Read-Host "Supprimer les volumes PostgreSQL ? (oui/non)"
        if ($confirm -eq "oui") {
            Set-Location $BackendDir
            docker compose down -v
            docker system prune -f
            Write-Host "Nettoyage termine." -ForegroundColor Green
        } else {
            Write-Host "Annule." -ForegroundColor Yellow
        }
    }

    "apk" {
        Write-Header "Build APK Flutter"
        Assert-Docker
        $outDir = Join-Path $PSScriptRoot "out"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        Write-Host "Construction de l'image Flutter (peut prendre 15-20 min)..." -ForegroundColor Yellow
        docker build -f (Join-Path $PSScriptRoot "Dockerfile.flutter") -t ecorewind-flutter $PSScriptRoot
        docker run --rm -v "${outDir}:/out" ecorewind-flutter
        Write-Host ""
        Write-Host "APK disponible : $outDir\ecorewind.apk" -ForegroundColor Green
    }

    default {
        Write-Host ""
        Write-Host "EcoRewind - Script de developpement" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Usage : .\dev.ps1 [commande]" -ForegroundColor White
        Write-Host ""
        Write-Host "Commandes disponibles :" -ForegroundColor White
        Write-Host "  start    Demarre l'API + PostgreSQL (Docker)" -ForegroundColor Gray
        Write-Host "  stop     Arrete tous les conteneurs" -ForegroundColor Gray
        Write-Host "  restart  Redemarrage complet" -ForegroundColor Gray
        Write-Host "  logs     Affiche les logs en temps reel" -ForegroundColor Gray
        Write-Host "  build    Reconstruit les images Docker" -ForegroundColor Gray
        Write-Host "  migrate  Applique les migrations Alembic" -ForegroundColor Gray
        Write-Host "  status   Affiche l'etat des conteneurs" -ForegroundColor Gray
        Write-Host "  clean    Supprime conteneurs + volumes (reset)" -ForegroundColor Gray
        Write-Host "  apk      Compile l'APK Flutter en Docker" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Exemples :" -ForegroundColor White
        Write-Host "  .\dev.ps1 start" -ForegroundColor DarkGray
        Write-Host "  .\dev.ps1 logs" -ForegroundColor DarkGray
        Write-Host "  .\dev.ps1 apk" -ForegroundColor DarkGray
    }
}
