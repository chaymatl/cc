@echo off
chcp 65001 >nul
title EcoRewind - Sauvegarde Base de Donnees

set "BACKUP_DIR=C:\Users\lenovo\Desktop\EcoRewind\backups"
set "INIT_SQL=C:\Users\lenovo\Desktop\EcoRewind\backend\backup_ecorewind.sql"

:: Generer un nom de fichier avec date/heure
for /f "tokens=1-3 delims=/" %%a in ("%DATE%") do set "D=%%c-%%b-%%a"
for /f "tokens=1-2 delims=:" %%a in ("%TIME: =0%") do set "T=%%a%%b"
set "BACKUP_FILE=%BACKUP_DIR%\ecorewind_%D%_%T%.sql"
set "LATEST_FILE=%BACKUP_DIR%\ecorewind_LATEST.sql"

echo.
echo =====================================================
echo   ECOREWIND - SAUVEGARDE BASE DE DONNEES
echo =====================================================
echo.

:: Creer le dossier backups si inexistant
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Verifier que Docker postgres tourne
docker ps --filter "name=ecorewind_postgres" --filter "status=running" --format "{{.Names}}" 2>nul | findstr "ecorewind_postgres" >nul
if errorlevel 1 (
    echo [ERREUR] Le conteneur ecorewind_postgres n'est pas actif.
    echo Lancez d'abord Docker.
    pause & exit /b 1
)

echo Sauvegarde en cours...

:: pg_dump dans le conteneur puis copie vers le PC
docker exec ecorewind_postgres pg_dump -U postgres -d ecorewind --no-owner --no-acl > "%BACKUP_FILE%"
if errorlevel 1 (
    echo [ERREUR] pg_dump a echoue.
    del "%BACKUP_FILE%" >nul 2>&1
    pause & exit /b 1
)

:: Copier vers LATEST et vers backend/backup_ecorewind.sql (init Docker)
copy /Y "%BACKUP_FILE%" "%LATEST_FILE%" >nul
copy /Y "%BACKUP_FILE%" "%INIT_SQL%" >nul

for %%f in ("%BACKUP_FILE%") do set "SIZE=%%~zf"
echo.
echo [OK] Sauvegarde : %BACKUP_FILE%
echo [OK] LATEST mis a jour : %LATEST_FILE%
echo [OK] Init Docker mis a jour : %INIT_SQL%
echo     Taille : %SIZE% octets
echo.

:: Garder seulement les 10 derniers backups horodates
set COUNT=0
for /f "skip=10 delims=" %%f in ('dir /b /o-d "%BACKUP_DIR%\ecorewind_20*.sql" 2^>nul') do (
    del "%BACKUP_DIR%\%%f" >nul 2>&1
)

echo =====================================================
echo   Sauvegarde complete !
echo   Dossier : %BACKUP_DIR%
echo =====================================================
echo.
timeout /t 3 /nobreak >nul
