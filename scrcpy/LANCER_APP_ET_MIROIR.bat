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

REM ============================================================
REM  ETAPE 1 : Telephone
REM ============================================================
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

REM ============================================================
REM  ETAPE 2 : Backend - pas de blocs imbriques, on utilise goto
REM ============================================================
echo [2/5] Verification du backend local...
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if not errorlevel 1 goto :BACKEND_OK

REM Port libre - demarrer le backend
echo  Demarrage backend local...
start "Backend EcoRewind" /D "%BKD%" cmd /k "%VENV% run_local.py"
echo  Attente demarrage (max 30s)...
set "TRIES=0"

:WAIT_BACKEND
if %TRIES%==10 goto :BACKEND_TIMEOUT
timeout /t 3 /nobreak >nul
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if not errorlevel 1 goto :BACKEND_STARTED
set /a TRIES+=1
goto :WAIT_BACKEND

:BACKEND_TIMEOUT
echo  Backend pas encore pret - continuons quand meme.
goto :STEP3

:BACKEND_STARTED
echo  [OK] Backend demarre
goto :STEP3

:BACKEND_OK
echo  [OK] Backend deja actif sur port 8000.

:STEP3
echo.

REM ============================================================
REM  ETAPE 3 : Tunnel ADB
REM ============================================================
echo [3/5] Activation tunnel USB...
"%ADB%" -s !DEVICE! reverse tcp:8000 tcp:8000
echo  [OK] Tunnel actif
echo.

REM ============================================================
REM  ETAPE 4 : Flutter
REM ============================================================
echo [4/5] Lancement de Flutter...
start "Flutter EcoRewind" /D "%PRJ%" cmd /k "%FLT% run -d !DEVICE!"
echo  [OK] Flutter lance
timeout /t 5 /nobreak >nul
echo.

REM ============================================================
REM  ETAPE 5 : Miroir scrcpy
REM ============================================================
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
