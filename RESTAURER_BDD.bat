@echo off
chcp 65001 >nul
title EcoRewind - Restauration Base de Donnees

set "BACKUP_DIR=C:\Users\lenovo\Desktop\EcoRewind\backups"
set "LATEST_FILE=%BACKUP_DIR%\ecorewind_LATEST.sql"
set "PSQL=C:\Program Files\PostgreSQL\15\bin\psql.exe"
set "PGPASSWORD=postgres"

echo.
echo =====================================================
echo   ECOREWIND - RESTAURATION BASE DE DONNEES
echo   ATTENTION : Ecrase les donnees actuelles !
echo =====================================================
echo.

if not exist "%LATEST_FILE%" (
    echo [ERREUR] Aucune sauvegarde trouvee dans %BACKUP_DIR%
    echo Lancez d'abord SAUVEGARDER_BDD.bat
    pause
    exit /b 1
)

echo Fichiers disponibles :
echo.
dir /b /o-d "%BACKUP_DIR%\ecorewind_*.sql" 2>nul
echo.
echo Par defaut : ecorewind_LATEST.sql
echo.
set /p CHOIX="Appuyez sur ENTREE pour LATEST, ou tapez un nom de fichier : "
if "%CHOIX%"=="" set "RESTORE_FILE=%LATEST_FILE%"
if not "%CHOIX%"=="" set "RESTORE_FILE=%BACKUP_DIR%\%CHOIX%"

echo.
echo Fichier : %RESTORE_FILE%
echo.
set /p CONFIRM="Confirmer ? (oui/non) : "
if /i not "%CONFIRM%"=="oui" (
    echo Restauration annulee.
    pause
    exit /b 0
)

echo.
echo Restauration en cours...
"%PSQL%" -h localhost -p 5432 -U postgres -d ecorewind -f "%RESTORE_FILE%"
if errorlevel 1 (
    echo [ERREUR] Restauration echouee.
    pause
    exit /b 1
)

echo.
echo [OK] Restauration terminee !
pause
