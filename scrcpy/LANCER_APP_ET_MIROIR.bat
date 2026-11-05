@echo off
REM Auto-relance dans cmd /k pour garder la fenetre ouverte
if "%~1"=="GO" goto :MAIN
cmd /k "%~f0" GO
exit /b

:MAIN
setlocal enabledelayedexpansion
title EcoRewind - Lancement Complet

echo.
echo =====================================================
echo   ECOREWIND - LANCEMENT COMPLET
echo   Backend local + Flutter + Miroir
echo =====================================================
echo.

REM === Chemins absolus ===
set "ADB=%~dp0scrcpy-win64-v3.3.4\adb.exe"
set "SCRCPY=%~dp0scrcpy-win64-v3.3.4\scrcpy.exe"
set "BKD=C:\Users\lenovo\Desktop\EcoRewind\backend"
set "VENV=C:\Users\lenovo\Desktop\EcoRewind\backend\venv\Scripts\python.exe"
set "FLT=C:\flutter\bin\flutter.bat"
set "PRJ=C:\Users\lenovo\Desktop\EcoRewind"

if not exist "%ADB%"    ( echo [ERREUR] ADB introuvable      & pause & exit /b 1 )
if not exist "%SCRCPY%" ( echo [ERREUR] SCRCPY introuvable   & pause & exit /b 1 )
if not exist "%FLT%"    ( echo [ERREUR] Flutter introuvable  & pause & exit /b 1 )
if not exist "%VENV%"   ( echo [ERREUR] VENV introuvable     & pause & exit /b 1 )
if not exist "%BKD%\run_local.py" ( echo [ERREUR] run_local.py manquant & pause & exit /b 1 )
echo  [OK] Tous les outils trouves.
echo.

REM === Etape 1 : Telephone ===
echo [1/5] Recherche du telephone USB...
"%ADB%" start-server >nul 2>&1
timeout /t 2 /nobreak >nul
"%ADB%" devices > "%TEMP%\ecorewind_devs.txt" 2>nul
set "DEVICE="
for /f "skip=1 tokens=1" %%d in (%TEMP%\ecorewind_devs.txt) do (
    if not "%%d"=="" if not "%%d"=="*" set "DEVICE=%%d"
)
if "!DEVICE!"=="" (
    echo  [ERREUR] Aucun telephone detecte.
    echo  Branchez le telephone et activez le debogage USB.
    pause
    exit /b 1
)
echo  [OK] Telephone : !DEVICE!
echo.

REM === Etape 2 : Backend LOCAL ===
echo [2/5] Verification du backend local...
netstat -ano 2>nul | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
    echo  Demarrage backend local...
    start "Backend EcoRewind" /D "%BKD%" cmd /k "%VENV% run_local.py"
    echo  Attente demarrage (max 30s)...
    set "READY=0"
    for /L %%i in (1,1,10) do (
        if !READY!==0 (
            timeout /t 3 /nobreak >nul
            netstat -ano 2>nul | findstr ":8000" | findstr "LISTENING" >nul 2>&1
            if not errorlevel 1 set "READY=1"
        )
    )
    if !READY!==0 ( echo  Backend pas encore pret - continuons quand meme. ) else ( echo  [OK] Backend demarre )
) else (
    echo  [OK] Backend deja actif sur port 8000.
)
echo.

REM === Etape 3 : Tunnel ===
echo [3/5] Activation tunnel USB...
"%ADB%" -s !DEVICE! reverse tcp:8000 tcp:8000
echo  [OK] Tunnel actif
echo.

REM === Etape 4 : Flutter ===
echo [4/5] Lancement de Flutter...
start "Flutter EcoRewind" /D "%PRJ%" cmd /k "%FLT% run -d !DEVICE!"
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
