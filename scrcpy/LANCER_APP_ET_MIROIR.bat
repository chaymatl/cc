@echo off
setlocal enabledelayedexpansion
title EcoRewind - Lancement Complet

REM ADB inclus dans scrcpy (toujours present)
set "ADB=%~dp0scrcpy-win64-v3.3.4\adb.exe"
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

REM === Verification fichiers critiques ===
if not exist "%ADB%" (
    echo  [ERREUR] ADB introuvable : %ADB%
    pause & exit /b 1
)
if not exist "%SCRCPY%" (
    echo  [ERREUR] scrcpy introuvable : %SCRCPY%
    pause & exit /b 1
)
if not exist "%FLUTTER%" (
    echo  [ERREUR] Flutter introuvable : %FLUTTER%
    pause & exit /b 1
)
echo  [OK] Tous les outils trouves.
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
    echo  [ERREUR] Aucun telephone detecte.
    echo  Branchez le telephone + activez debogage USB
    echo.
    pause
    exit /b 1
)
echo  [OK] Telephone : !DEVICE!
echo.

REM === Etape 2 : Backend ===
echo [2/5] Verification du backend...
set "PORT_ACTIF=0"
netstat -ano > "%TEMP%\netstat8000.txt" 2>&1
findstr ":8000 " "%TEMP%\netstat8000.txt" | findstr "LISTEN" > "%TEMP%\port8000.txt" 2>&1
for %%f in ("%TEMP%\port8000.txt") do if %%~zf gtr 0 set "PORT_ACTIF=1"

if !PORT_ACTIF!==1 (
    echo  [OK] Backend deja actif sur port 8000 - aucune action.
) else (
    echo  Port 8000 libre - Demarrage backend local sur 127.0.0.1...
    if not exist "%VENV_PY%" (
        echo  [ERREUR] Python venv introuvable : %VENV_PY%
        pause & exit /b 1
    )
    start "Backend EcoRewind" cmd /k "cd /d %PROJECT%\backend && .\venv\Scripts\python.exe run_local.py"
    echo  Attente du demarrage...
    set "READY=0"
    for /L %%i in (1,1,10) do (
        if !READY!==0 (
            timeout /t 3 /nobreak >nul
            "%VENV_PY%" -c "import urllib.request,sys;urllib.request.urlopen('http://127.0.0.1:8000/docs',timeout=2);sys.exit(0)" >nul 2>&1
            if not errorlevel 1 set "READY=1"
        )
    )
    if !READY!==0 (
        echo  Backend pas encore pret. Appuyez sur une touche pour continuer.
        pause >nul
    ) else (
        echo  [OK] Backend demarre sur 127.0.0.1:8000
    )
)
echo.

REM === Etape 3 : Tunnel ===
echo [3/5] Activation tunnel USB...
"%ADB%" -s !DEVICE! reverse tcp:8000 tcp:8000
echo  [OK] Tunnel actif
echo.

REM === Etape 4 : Flutter ===
echo [4/5] Lancement de Flutter...
start "Flutter EcoRewind" cmd /k "cd /d %PROJECT% && "%FLUTTER%" run -d !DEVICE!"
echo  [OK] Flutter lance
timeout /t 5 /nobreak >nul
echo.

REM === Etape 5 : Miroir ===
echo [5/5] Lancement du miroir scrcpy...
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
