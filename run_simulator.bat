@echo off
set SDK_BIN=C:\Users\naufa\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin
echo ========================================================
echo   Launching Garmin Forerunner 165 Simulator
echo ========================================================
echo [1/2] Opening Garmin Simulator window...
start "" "%SDK_BIN%\simulator.exe"
timeout /t 3 /nobreak >nul
echo [2/2] Loading GuitarPrompter.prg onto Forerunner 165...
call "%SDK_BIN%\monkeydo.bat" "%~dp0bin\GuitarPrompter.prg" fr165
echo.
echo Application is now running in simulator!
pause
