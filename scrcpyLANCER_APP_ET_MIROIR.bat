@echo off
chcp 65001 >nul
title EcoRewind - Lancer App + Miroir

set SCRCPY_DIR=%~dp0scrcpy\scrcpy-win64-v3.3.4
set ADB=%SCRCPY_DIR%\adb.exe
set SCRCPY=%SCRCPY_DIR%\scrcpy.exe
set APK=%~dp0build\app\outputs\flutter-apk\app-debug.apk
set PACKAGE=com.example.eco_rewind
set BACKEND_DIR=%~dp0backend

echo.
echo  ============================================================
echo    EcoRewind - Lancement App Android + Miroir scrcpy
echo  ============================================================
echo.

:: =================================================================
:: ETAPE 1 : Verifier telephone USB
:: =================================================================
echo [1/5] Verification du telephone connecte...
"%ADB%" devices | findstr /v "List of devices" | findstr "device" >nul
if errorlevel 1 (
    echo.
    echo  !! ERREUR : Aucun telephone detecte !
    echo.
    echo     Verifiez que :
    echo       1. Le cable USB est bien branche
    echo       2. Le debogage USB est active sur le telephone
    echo       3. Vous avez accepte "Autoriser le debogage USB"
    echo.
    pause
    exit /b 1
)
echo     OK - Telephone detecte.

:: =================================================================
:: ETAPE 1b : Tunnel ADB
:: =================================================================
echo.
echo [1b] Configuration du tunnel USB (adb reverse)...
"%ADB%" reverse tcp:8000 tcp:8000
echo     OK - Tunnel actif : telephone->127.0.0.1:8000

:: =================================================================
:: ETAPE 2 : Verifier backend (NE PAS relancer si deja actif)
:: =================================================================
echo.
echo [2/5] Verification du backend...

:: Methode robuste : verifier directement si port 8000 ecoute
netstat -ano | findstr "0.0.0.0:8000" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo     OK - Port 8000 actif ^(Docker ou autre^).
    goto backend_ok
)
netstat -ano | findstr "[::]:8000" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo     OK - Port 8000 actif ^(IPv6^).
    goto backend_ok
)
netstat -ano | findstr "127.0.0.1:8000" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo     OK - Port 8000 actif ^(loopback^).
    goto backend_ok
)

:: Port 8000 libre -> demarrer backend local sur 127.0.0.1 UNIQUEMENT
echo     Port 8000 libre - Demarrage backend local sur 127.0.0.1:8000...
start "EcoRewind Backend" cmd /k "cd /d "%BACKEND_DIR%" && .\venv\Scripts\python.exe run_local.py"
timeout /t 5 /nobreak >nul
echo     OK - Backend local demarre ^(127.0.0.1 = pas d'erreur Windows^).

:backend_ok

:: =================================================================
:: ETAPE 3 : Installer l'APK
:: =================================================================
echo.
echo [3/5] Installation de l'APK sur le telephone...
if not exist "%APK%" (
    echo     APK introuvable - Construction en cours...
    cd /d "%~dp0"
    call flutter build apk --debug
    if errorlevel 1 (
        echo  ERREUR: Build Flutter echoue.
        pause
        exit /b 1
    )
)
"%ADB%" install -r "%APK%"
if errorlevel 1 (
    echo.
    echo  ERREUR: Installation APK echouee.
    echo  Desinstallez l'app sur le telephone puis relancez.
    pause
    exit /b 1
)
echo     OK - APK installe.

:: =================================================================
:: ETAPE 4 : Lancer l'app
:: =================================================================
echo.
echo [4/5] Lancement de l'application...
"%ADB%" shell monkey -p %PACKAGE% -c android.intent.category.LAUNCHER 1 >nul 2>&1
timeout /t 2 /nobreak >nul
echo     OK - Application lancee.

:: =================================================================
:: ETAPE 5 : Miroir scrcpy
:: =================================================================
echo.
echo [5/5] Ouverture du miroir scrcpy...
echo.
echo  ============================================================
echo    Miroir actif - Fermez cette fenetre pour arreter
echo  ============================================================
echo.
"%SCRCPY%" --window-title "EcoRewind - Miroir" --stay-awake --turn-screen-off --max-fps 60 --video-bit-rate 8M
