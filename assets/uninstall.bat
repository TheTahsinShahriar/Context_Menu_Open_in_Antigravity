@echo off
echo Starting Cleanup...
echo.

:: ---------------------------------------------------------
:: 1. Remove Legacy Context Menu
:: ---------------------------------------------------------
echo [1/2] Removing Legacy Context Menu...

reg delete "HKCU\Software\Classes\*\shell\OpenInAntigravity" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\OpenInAntigravity" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\OpenInAntigravity" /f >nul 2>&1

echo [INFO] Legacy Registry keys cleanup attempted.

:: ---------------------------------------------------------
:: 2. Remove Modern Windows 11 Context Menu
:: ---------------------------------------------------------
echo [2/2] Removing Modern Windows 11 Menu Config...

set "APP_CONFIG_DIR="
for /d %%D in ("%LOCALAPPDATA%\Packages\*CustomContextMenu*") do (
    if exist "%%D\LocalState" set "APP_CONFIG_DIR=%%D\LocalState\custom_commands"
)

if "%APP_CONFIG_DIR%"=="" goto :skip_modern

if exist "%APP_CONFIG_DIR%\Open in Antigravity.json" (
    del /F "%APP_CONFIG_DIR%\Open in Antigravity.json" >nul 2>&1
    echo [SUCCESS] Config file removed.
) else (
    echo [INFO] Config file already gone.
)
goto :end

:skip_modern
echo [INFO] App folder not found.

:end
echo.
echo ==========================================
echo   CLEANUP COMPLETED
echo ==========================================
echo.
if not "%IN_MENU%"=="1" pause
