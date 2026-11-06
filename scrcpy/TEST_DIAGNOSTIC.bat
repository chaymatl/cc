@echo off
echo === TEST DEBUT ===
pause

set "ADB=%~dp0scrcpy-win64-v3.3.4\adb.exe"
set "SCRCPY=%~dp0scrcpy-win64-v3.3.4\scrcpy.exe"
set "PROJECT=C:\Users\lenovo\Desktop\EcoRewind"
set "VENV_PY=%PROJECT%\backend\venv\Scripts\python.exe"
set "FLUTTER=C:\flutter\bin\flutter.bat"

echo ADB      = %ADB%
echo SCRCPY   = %SCRCPY%
echo VENV_PY  = %VENV_PY%
echo FLUTTER  = %FLUTTER%
echo.

if exist "%ADB%" (echo [OK] ADB existe) else (echo [MANQUANT] ADB introuvable)
if exist "%SCRCPY%" (echo [OK] SCRCPY existe) else (echo [MANQUANT] SCRCPY introuvable)
if exist "%VENV_PY%" (echo [OK] VENV_PY existe) else (echo [MANQUANT] VENV_PY introuvable)
if exist "%FLUTTER%" (echo [OK] FLUTTER existe) else (echo [MANQUANT] FLUTTER introuvable)

echo.
echo === TEST TERMINE ===
pause
