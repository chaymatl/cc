@echo off
chcp 65001 >nul
title EcoRewind - Lancement complet

echo.
echo  ========================================
echo    EcoRewind - Demarrage en cours...
echo  ========================================
echo.

:: Backend via Docker si disponible, sinon 127.0.0.1 local
echo [1/2] Demarrage du backend...
docker ps --filter "name=ecorewind_api" --filter "status=running" --format "{{.Names}}" 2>nul | findstr "ecorewind_api" >nul
if not errorlevel 1 (
    echo     OK - Backend Docker actif.
    goto run_flutter
)
netstat -an 2>nul | findstr ":8000 " | findstr "LISTENING" >nul
if not errorlevel 1 (
    echo     OK - Port 8000 deja actif.
    goto run_flutter
)
docker start ecorewind_api ecorewind_postgres 2>nul
timeout /t 3 /nobreak >nul
docker ps --filter "name=ecorewind_api" --filter "status=running" --format "{{.Names}}" 2>nul | findstr "ecorewind_api" >nul
if not errorlevel 1 (
    echo     OK - Docker demarre.
    goto run_flutter
)
echo     Demarrage backend local sur 127.0.0.1:8000...
start "EcoRewind Backend" cmd /k "cd /d "%~dp0backend" && .\venv\Scripts\python.exe run_local.py"
timeout /t 4 /nobreak >nul

:run_flutter
echo [2/2] Demarrage de Flutter (Chrome)...
flutter run -d chrome
