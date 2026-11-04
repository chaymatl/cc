@echo off
chcp 65001 >nul
title EcoRewind - Sauvegarde Base de Donnees (locale)

set "BACKUP_DIR=C:\Users\lenovo\Desktop\EcoRewind\backups"
set "INIT_SQL=C:\Users\lenovo\Desktop\EcoRewind\backend\backup_ecorewind.sql"
set "PGDUMP=C:\Program Files\PostgreSQL\15\bin\pg_dump.exe"
set "PGHOST=localhost"
set "PGPORT=5432"
set "PGUSER=postgres"
set "PGDATABASE=ecorewind"

REM Generer un nom de fichier avec date/heure
for /f "tokens=1-3 delims=/" %%a in ("%DATE%") do set "D=%%c-%%b-%%a"
for /f "tokens=1-2 delims=: " %%a in ("%TIME: =0%") do set "T=%%a%%b"
set "BACKUP_FILE=%BACKUP_DIR%\ecorewind_%D%_%T%.sql"
set "LATEST_FILE=%BACKUP_DIR%\ecorewind_LATEST.sql"

echo.
echo =====================================================
echo   ECOREWIND - SAUVEGARDE BASE DE DONNEES
echo   PostgreSQL local : %PGHOST%:%PGPORT%/%PGDATABASE%
echo =====================================================
echo.

REM Creer le dossier backups si inexistant
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Verifier que pg_dump existe
if not exist "%PGDUMP%" (
    echo [ERREUR] pg_dump introuvable : %PGDUMP%
    pause & exit /b 1
)

echo Sauvegarde en cours...

REM pg_dump direct sur la base locale (pas de Docker)
"%PGDUMP%" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% --no-owner --no-acl > "%BACKUP_FILE%"
if errorlevel 1 (
    echo [ERREUR] pg_dump a echoue.
    echo Verifiez que PostgreSQL local tourne sur le port %PGPORT%.
    del "%BACKUP_FILE%" >nul 2>&1
    pause & exit /b 1
)

REM Copier vers LATEST (1 seule copie - comme demande)
copy /Y "%BACKUP_FILE%" "%LATEST_FILE%" >nul
copy /Y "%BACKUP_FILE%" "%INIT_SQL%" >nul

for %%f in ("%BACKUP_FILE%") do set "SIZE=%%~zf"
echo.
echo [OK] Sauvegarde : %BACKUP_FILE%
echo [OK] LATEST mis a jour : %LATEST_FILE%
echo     Taille : %SIZE% octets
echo.

REM Garder seulement les 5 derniers backups horodates (1 copie par sauvegarde)
for /f "skip=5 delims=" %%f in ('dir /b /o-d "%BACKUP_DIR%\ecorewind_20*.sql" 2^>nul') do (
    del "%BACKUP_DIR%\%%f" >nul 2>&1
)

echo =====================================================
echo   Sauvegarde complete !
echo   Dossier : %BACKUP_DIR%
echo =====================================================
echo.
timeout /t 3 /nobreak >nul
