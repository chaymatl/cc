@echo off
setlocal enabledelayedexpansion
title EcoRewind - Lancement Complet

set "ADB=C:\Users\lenovo\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set "SCRCPY=%~dp0scrcpy-win64-v3.3.4\scrcpy.exe"
set "PROJECT=C:\Users\lenovo\Desktop\EcoRewind"
set "VENV_PY=%PROJECT%\backend\venv\Scripts\python.exe"
set "FLUTTER=C:\flutter\bin\flutter.bat"

echo.
echo =====================================================
echo   ECOREWIND - LANCEMENT COMPLET
echo   Backend + Tunnel ADB + Flutter + Miroir
echo =====================================================
echo.

REM === Etape 1 : Telephone ===
echo [1/5] Recherche du telephone USB...
"%ADB%" start-server >nul 2>&1
timeout /t 2 /nobreak >nul
"%ADB%" devices > "%TEMP%\ecorewind_devs.txt" 2>nul
set "DEVICE="
for /f "skip=1 tokens=1" %%d in (%TEMP%\ecorewind_devs.txt) do (
    if not "%%d"=="" set "DEVICE=%%d"
)
if "!DEVICE!"=="" (
    echo.
    echo  [!] Aucun telephone detecte.
    echo      Branchez le telephone + activez debogage USB
    echo.
    pause
    exit /b 1
)
echo  [OK] Telephone : !DEVICE!
echo.

REM === Etape 2 : Backend ===
echo [2/5] Lancement du backend...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 " ^| findstr "LISTEN"') do (
    echo  Ancien backend PID %%p - arret...
    taskkill /F /PID %%p >nul 2>&1
    timeout /t 1 /nobreak >nul
)
start "Backend EcoRewind" cmd /k "cd /d %PROJECT%\backend && .\venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000"
echo  Attente du demarrage (max 30s)...
set "READY=0"
for /L %%i in (1,1,10) do (
    if !READY!==0 (
        timeout /t 3 /nobreak >nul
        "%VENV_PY%" -c "import urllib.request,sys;urllib.request.urlopen('http://127.0.0.1:8000/docs',timeout=2);sys.exit(0)" >nul 2>&1
        if not errorlevel 1 set "READY=1"
    )
)
if !READY!==0 (
    echo  Appuyez sur une touche quand le backend est pret.
    pause >nul
) else (
    echo  [OK] Backend demarre !
)
echo.

REM === Etape 3 : Tunnel ===
echo [3/5] Activation tunnel USB...
"%ADB%" -s !DEVICE! reverse tcp:8000 tcp:8000 >nul 2>&1
echo  [OK] Tunnel actif
echo.

REM === Etape 4 : Flutter ===
echo [4/5] Lancement de Flutter...
start "Flutter EcoRewind" cmd /k "cd /d %PROJECT% && "%FLUTTER%" run -d !DEVICE!"
echo  [OK] Flutter lance
timeout /t 5 /nobreak >nul
echo.

REM === Etape 5 : Miroir ===
echo [5/5] Lancement du miroir...
echo.
echo =====================================================
echo   TOUT EST LANCE !
echo   Fermez cette fenetre pour arreter le miroir
echo =====================================================
echo.
"%SCRCPY%" -s !DEVICE! --window-title "EcoRewind" --max-size 1080 --stay-awake

echo.
echo Miroir ferme.
pause
endlocal