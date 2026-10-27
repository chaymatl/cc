@echo off
title EcoRewind - Backend Docker
cd /d "%~dp0backend"

echo =====================================================
echo   ECOREWIND - DEMARRAGE DU BACKEND DOCKER
echo =====================================================
echo.

:: Verifier que Docker est lance
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Docker n'est pas en cours d'execution.
    echo Lancez Docker Desktop puis relancez ce script.
    pause
    exit /b 1
)

:: Verifier que .env existe
if not exist ".env" (
    echo [ATTENTION] Fichier .env absent.
    echo Copie de .env.example vers .env...
    copy ".env.example" ".env" >nul
    echo Editez le fichier backend\.env avec vos valeurs avant de continuer.
    pause
    exit /b 1
)

:: Verifier que firebase_credentials.json existe
if not exist "firebase_credentials.json" (
    echo [ATTENTION] firebase_credentials.json absent du dossier backend/.
    echo Le backend demarrera en mode degrade sans Firebase.
)

echo.
echo Choisissez un profil de demarrage :
echo   [1] API seule          (PostgreSQL local requis sur port 5432)
echo   [2] API + PostgreSQL   (recommande - tout en Docker)
echo   [3] API + PG + Worker IA (complet)
echo.
set /p CHOIX="Votre choix (1/2/3) : "

if "%CHOIX%"=="1" (
    echo.
    echo [1/3] Liberation du port 8000...
    for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 " ^| findstr "LISTEN"') do (
        taskkill /F /PID %%p >nul 2>&1
    )
    echo [2/3] Demarrage de l'API seule...
    docker compose up --build -d api
) else if "%CHOIX%"=="2" (
    echo.
    echo [1/3] Liberation du port 8000...
    for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 " ^| findstr "LISTEN"') do (
        taskkill /F /PID %%p >nul 2>&1
    )
    echo [2/3] Demarrage API + PostgreSQL...
    docker compose --profile standalone up --build -d
) else if "%CHOIX%"=="3" (
    echo.
    echo [1/3] Liberation du port 8000...
    for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8000 " ^| findstr "LISTEN"') do (
        taskkill /F /PID %%p >nul 2>&1
    )
    echo [2/3] Demarrage complet (API + PG + IA)...
    docker compose --profile full up --build -d
) else (
    echo Choix invalide.
    pause
    exit /b 1
)

echo.
echo [3/3] Verification des conteneurs...
timeout /t 5 /nobreak >nul
docker compose ps

echo.
echo =====================================================
echo   BACKEND DOCKER EST PRET SUR http://localhost:8000
echo   Docs API  : http://localhost:8000/docs
echo.
echo   Logs      : docker compose logs -f api
echo   Arreter   : docker compose down
echo   Reset DB  : docker compose down -v
echo =====================================================
echo.
pause
