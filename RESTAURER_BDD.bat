@echo off
chcp 65001 >nul
title EcoRewind - Restauration Base de Donnees

set "BACKUP_DIR=C:\Users\lenovo\Desktop\EcoRewind\backups"
set "LATEST_FILE=%BACKUP_DIR%\ecorewind_LATEST.sql"

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
set /p CHOIX="Appuyez sur ENTREE pour restaurer LATEST, ou tapez le nom d'un autre fichier : "
if "%CHOIX%"=="" set "CHOIX=%LATEST_FILE%"
if not exist "%BACKUP_DIR%\%CHOIX%" (
    if exist "%CHOIX%" set "RESTORE_FILE=%CHOIX%"
) else (
    set "RESTORE_FILE=%BACKUP_DIR%\%CHOIX%"
)
if "%RESTORE_FILE%"=="" set "RESTORE_FILE=%LATEST_FILE%"

echo.
echo Fichier a restaurer : %RESTORE_FILE%
echo.
set /p CONFIRM="Confirmer la restauration ? (oui/non) : "
if /i not "%CONFIRM%"=="oui" (
    echo Restauration annulee.
    pause
    exit /b 0
)

echo.
echo Restauration en cours...
docker exec -i ecorewind_postgres psql -U postgres -d ecorewind < "%RESTORE_FILE%"
if errorlevel 1 (
    echo [ERREUR] Restauration echouee.
    pause
    exit /b 1
)

echo.
echo [OK] Restauration terminee avec succes !
pause
