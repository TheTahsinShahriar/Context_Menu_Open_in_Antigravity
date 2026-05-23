@echo off
echo ==========================================
echo   Open in Antigravity - Setup Menu
echo ==========================================
echo.
echo Starting PowerShell with execution policy bypass...
echo.

:: Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

:: Launch PowerShell with bypass and run the ps1 script from assets folder
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%assets\setup.ps1"

:: Pause to see any errors
echo.
if %errorlevel% neq 0 (
    echo [ERROR] Script exited with code %errorlevel%
    pause
)
