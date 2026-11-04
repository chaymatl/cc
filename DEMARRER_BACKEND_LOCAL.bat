@echo off
chcp 65001 >nul
title EcoRewind - Backend Local

echo.
echo  =========================================================
echo    EcoRewind - Backend LOCAL (127.0.0.1:8000)
echo    Utilise 127.0.0.1 au lieu de 0.0.0.0
echo    pour eviter l'erreur Windows [Errno 13]
echo  =========================================================
echo.

:: Verifier si port 8000 deja occupe
netstat -an 2>nul | findstr ":8000 " | findstr "LISTENING" >nul
if not errorlevel 1 (
    echo  [INFO] Port 8000 deja occupe. Backend probablement actif.
    echo  Verifiez http://localhost:8000/docs
    pause
    exit /b 0
)

cd /d "%~dp0backend"

:: Verifier venv
if not exist ".\venv\Scripts\python.exe" (
    echo  [ERREUR] venv Python introuvable dans backend\venv\
    echo  Creez-le avec : python -m venv venv
    pause
    exit /b 1
)

echo  Demarrage sur 127.0.0.1:8000 (loopback - pas de permission requise)...
echo  Docs API : http://127.0.0.1:8000/docs
echo.
.\venv\Scripts\python.exe run_local.py
