# PowerShell Setup Wrapper for "Open in Antigravity"
# Usage: irm <url> | iex
# Note: If running as a file, use: powershell -ExecutionPolicy Bypass -File setup.ps1

# Trap unhandled errors to prevent window from closing immediately
trap {
    Write-Host "`n[CRITICAL ERROR] $_" -ForegroundColor Red
    Write-Host "`nStack Trace: $($_.ScriptStackTrace)" -ForegroundColor DarkGray
    Read-Host "`nPress Enter to exit..."
    exit 1
}

$ErrorActionPreference = "Continue"
$RepoBaseUrl = "https://raw.githubusercontent.com/TheTahsinShahriar/Open-in-Antigravity/main"
$TempDir = "$env:TEMP\OpenInAntigravitySetup"

function Show-Header {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   Open in Antigravity - Setup Menu"
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Initialize-Files {
    # 1. Check if running locally (install.bat exists in same directory as this script)
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { "." }
    
    if (Test-Path (Join-Path $scriptDir "install.bat")) {
        return $scriptDir
    }

    # 2. If not local, assume remote execution and download files
    Write-Host "Remote execution detected. Downloading files..." -ForegroundColor Yellow
    
    if (-not (Test-Path "$TempDir\assets")) {
        New-Item -Path "$TempDir\assets" -ItemType Directory -Force | Out-Null
    }

    try {
        # Download Installers from assets folder
        Invoke-WebRequest -Uri "$RepoBaseUrl/assets/install.bat" -OutFile "$TempDir\assets\install.bat" -UseBasicParsing
        Invoke-WebRequest -Uri "$RepoBaseUrl/assets/uninstall.bat" -OutFile "$TempDir\assets\uninstall.bat" -UseBasicParsing
        
        # Download JSON config
        Invoke-WebRequest -Uri "$RepoBaseUrl/assets/Open%20in%20Antigravity.json" -OutFile "$TempDir\assets\Open in Antigravity.json" -UseBasicParsing
        
        Write-Host "Download complete." -ForegroundColor Green
        return "$TempDir\assets"
    } catch {
        Write-Host "[ERROR] Failed to download files from GitHub." -ForegroundColor Red
        Write-Host "Ensure the repository is public and the URL is correct."
        Write-Host "Error: $_"
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

# Main Execution
try {
    $WorkDir = Initialize-Files

    while ($true) {
        Show-Header
        Write-Host "This script will launch the Batch installers."
        Write-Host ""
        Write-Host "1. Install 'Open in Antigravity'"
        Write-Host "2. Uninstall 'Open in Antigravity'"
        Write-Host "3. Exit"
        Write-Host ""
        $choice = Read-Host "Select an option (1-3)"

        switch ($choice) {
            "1" {
                try {
                    $env:IN_MENU = "1"
                    cmd.exe /c "cd /d `"$WorkDir`" && install.bat"
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "[WARNING] Install.bat exited with code $LASTEXITCODE" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "[ERROR] Failed to start install.bat: $_" -ForegroundColor Red
                }
                Write-Host "`nPress Enter to continue ..." -NoNewline
                [void]$Host.UI.ReadLine()
            }
            "2" {
                try {
                    $env:IN_MENU = "1"
                    cmd.exe /c "cd /d `"$WorkDir`" && uninstall.bat"
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "[WARNING] Uninstall.bat exited with code $LASTEXITCODE" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "[ERROR] Failed to start uninstall.bat: $_" -ForegroundColor Red
                }
                Write-Host "`nPress Enter to continue ..." -NoNewline
                [void]$Host.UI.ReadLine()
            }
            "3" {
                # Cleanup temp if used
                if ($WorkDir -eq "$TempDir\assets" -and (Test-Path "$TempDir\assets\install.bat")) {
                    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "Cleaned up temporary files." -ForegroundColor Green
                }
                exit
            }
            default {
                Write-Host "Invalid option." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
} catch {
    Write-Host "`n[UNEXPECTED ERROR] $_" -ForegroundColor Red
    Write-Host "`nPress Enter to exit ..." -NoNewline
    [void]$Host.UI.ReadLine()
    exit 1
}
