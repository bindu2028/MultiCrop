@echo off
title MultiCrop Backend Server
echo ===================================================
echo Starting MultiCrop Flask Backend Server...
echo ===================================================
cd /d "%~dp0"
if exist .venv\Scripts\activate.bat (
    echo Activating Python virtual environment...
    call .venv\Scripts\activate.bat
    echo Starting Flask app...
    python run.py
) else (
    echo ERROR: Virtual environment was not found.
    echo Please make sure the .venv folder exists.
    pause
)
