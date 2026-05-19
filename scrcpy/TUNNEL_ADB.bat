@echo off
setlocal enabledelayedexpansion
title EcoRewind - Tunnel ADB

set "ADB=C:\Users\lenovo\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo.
echo  =========================================
echo   ECOREWIND - ACTIVATION TUNNEL ADB
echo  =========================================
echo.

:: Detecter le telephone
"%ADB%" start-server >nul 2>&1
timeout /t 1 /nobreak >nul

set "DEVICE="
for /f "skip=1 tokens=1" %%d in ('"%ADB%" devices 2^>nul') do (
    set "LINE=%%d"
    if not "!LINE!"=="" (
        echo !LINE! | findstr /i "emulator" >nul
        if errorlevel 1 (
            set "DEVICE=!LINE!"
        )
    )
)

if "!DEVICE!"=="" (
    echo  [ERREUR] Aucun telephone detecte.
    echo    - Verifiez le cable USB
    echo    - Activez le debogage USB
    pause
    exit /b 1
)

echo  Telephone : !DEVICE!

:: Activer le tunnel
"%ADB%" -s !DEVICE! reverse tcp:8000 tcp:8000
if !errorlevel! NEQ 0 (
    echo  [ERREUR] Tunnel echoue
    pause
    exit /b 1
)

echo  [OK] Tunnel actif : telephone:8000 -^> PC:8000
echo.

:: Verifier que le backend repond
echo  Verification du backend...
python -c "import urllib.request; r=urllib.request.urlopen('http://127.0.0.1:8000/collection-points',timeout=3); print(f'  [OK] Backend OK - {len(__import__(\"json\").loads(r.read()))} points de tri')" 2>nul
if !errorlevel! NEQ 0 (
    echo  [ATTENTION] Backend non accessible sur le port 8000.
    echo    Lancez : cd backend ^& python -m uvicorn main:app --host 0.0.0.0 --port 8000
)

echo.
echo  Tunnel pret. Vous pouvez lancer Flutter.
echo  (Gardez cette fenetre ouverte)
echo.
pause
endlocal
