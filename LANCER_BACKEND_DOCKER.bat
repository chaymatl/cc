@echo off
title EcoRewind - Backend Docker
cd /d "%~dp0backend"

echo =====================================================
echo   ECOREWIND - DEMARRAGE DU BACKEND DOCKER
echo =====================================================
echo.

echo [1/3] Arret de tout ancien processus sur le port 8000...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 " ^| findstr "LISTEN"') do (
    echo  Arret PID local %%p...
    taskkill /F /PID %%p >nul 2>&1
)

echo.
echo [2/3] Construction et demarrage du conteneur Backend Docker...
docker compose up --build -d api

echo.
echo [3/3] Verification de la disponibilite du conteneur...
timeout /t 5 /nobreak >nul
docker compose ps

echo.
echo =====================================================
echo   BACKEND DOCKER EST PRET SUR http://localhost:8000
echo   Pour voir les logs : docker compose logs -f api
echo   Pour arreter       : docker compose down
echo =====================================================
echo.
pause
