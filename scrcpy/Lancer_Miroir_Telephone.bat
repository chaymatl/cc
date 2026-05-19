@echo off
title Miroir Telephone - EcoRewind
echo ================================================
echo     MIROIR ECRAN TELEPHONE - scrcpy v3.3.4
echo ================================================
echo.
echo ETAPE 1: Connectez votre telephone en USB
echo ETAPE 2: Activez le DEBOGAGE USB sur le telephone
echo   (Paramètres > À propos > Appuyer 7x sur N° de build
echo    puis Paramètres > Options développeur > Débogage USB ON)
echo.
echo Lancement du miroir...
echo.
cd /d "%~dp0scrcpy-win64-v3.3.4"
scrcpy.exe --window-title "EcoRewind - Mon Telephone" --max-size 1080 --no-audio
echo.
echo Ferme. Appuyez sur une touche pour quitter.
pause
