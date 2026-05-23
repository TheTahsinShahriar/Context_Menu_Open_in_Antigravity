@echo off
echo Starting Installation...
echo.

:: Define Paths
set "EXE_PATH=%LocalAppData%\Programs\Antigravity IDE\Antigravity IDE.exe"
set "ASSETS_DIR=%~dp0"

:: ---------------------------------------------------------
:: 1. Check Prerequisites
:: ---------------------------------------------------------

if exist "%EXE_PATH%" goto :check_assets
echo [CRITICAL ERROR] Antigravity application not found!
echo Expected at: "%EXE_PATH%"
echo.
echo Please install Antigravity first.
pause
exit /b 1

:check_assets
if exist "%ASSETS_DIR%\Open in Antigravity.json" goto :install_legacy
echo [CRITICAL ERROR] Assets missing.
echo Please ensure 'assets' folder is present in the same directory.
pause
exit /b 1

:: ---------------------------------------------------------
:: 2. Install Legacy Context Menu (Registry)
:: ---------------------------------------------------------
:install_legacy
echo [1/2] Installing Legacy Context Menu...

reg add "HKCU\Software\Classes\*\shell\OpenInAntigravity" /ve /d "Open in &Antigravity" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\*\shell\OpenInAntigravity" /v "Icon" /d "\"%EXE_PATH%\",0" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\*\shell\OpenInAntigravity\command" /ve /d "\"%EXE_PATH%\" \"%%1\"" /f >nul
if %errorlevel% neq 0 goto :reg_error

:: Folders
reg add "HKCU\Software\Classes\Directory\shell\OpenInAntigravity" /ve /d "Open in &Antigravity" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\Directory\shell\OpenInAntigravity" /v "Icon" /d "\"%EXE_PATH%\",0" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\Directory\shell\OpenInAntigravity\command" /ve /d "\"%EXE_PATH%\" \"%%1\"" /f >nul
if %errorlevel% neq 0 goto :reg_error

:: Background
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInAntigravity" /ve /d "Open in &Antigravity" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInAntigravity" /v "Icon" /d "\"%EXE_PATH%\",0" /f >nul
if %errorlevel% neq 0 goto :reg_error

reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInAntigravity\command" /ve /d "\"%EXE_PATH%\" \"%%V\"" /f >nul
if %errorlevel% neq 0 goto :reg_error

echo [SUCCESS] Legacy Menu enabled.
goto :install_modern

:reg_error
echo [ERROR] Registry mod failed. Run as Administrator.
pause
exit /b 1

:: ---------------------------------------------------------
:: 3. Install Modern Windows 11 Context Menu
:: ---------------------------------------------------------
:install_modern
echo [2/2] Installing Modern Windows 11 Menu Config...

:: Manual search to avoid delayed expansion issues
set "APP_CONFIG_DIR="
for /d %%D in ("%LOCALAPPDATA%\Packages\*CustomContextMenu*") do (
    if exist "%%D\LocalState" set "APP_CONFIG_DIR=%%D\LocalState\custom_commands"
)

if "%APP_CONFIG_DIR%"=="" goto :skip_modern

:: Create directory if missing
if not exist "%APP_CONFIG_DIR%" mkdir "%APP_CONFIG_DIR%"

:: Copy file
copy /Y "%ASSETS_DIR%\Open in Antigravity.json" "%APP_CONFIG_DIR%\Open in Antigravity.json" >nul
if %errorlevel% equ 0 goto :success_modern

echo [ERROR] Failed to copy config file.
goto :end

:success_modern
echo [SUCCESS] Modern Windows 11 Menu config applied.
goto :end

:skip_modern
echo.
echo [WARNING] "Custom Context Menu" app not found!
echo The Legacy menu (Shift+RightClick) is installed, but for the main menu,
echo you MUST install the "Custom Context Menu" app from the Microsoft Store or GitHub.
echo.
echo Opening Microsoft Store page for you...
start ms-windows-store://pdp/?ProductId=9pc7bzz28g0x
echo.
echo If you prefer GitHub, download the release here:
echo https://github.com/ikas-mc/ContextMenuForWindows11/releases/latest
echo.
echo After installing the app, run this script AGAIN.
goto :end

:: ---------------------------------------------------------
:: End
:: ---------------------------------------------------------
:end
echo.
echo ==========================================
echo   SETUP COMPLETED
echo ==========================================
echo.
if not "%IN_MENU%"=="1" pause
