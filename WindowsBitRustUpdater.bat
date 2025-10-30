@echo off
setlocal enabledelayedexpansion
rem =============================================
rem Automatic Updates For BitRust Factions | Necesse
rem BitRust Network - Click-to-Install Necesse Mods
rem AUTO-DOWNLOADS & UNZIPS from the latest Respo
rem UPDATED: Use Net.WebClient for download to avoid hanging, .NET unzip
rem =============================================
set "BRAND=BitRust Network"
set "GAME=Necesse"
set "VERSION=v1.0"
set "MOD_DIR=%APPDATA%\Necesse\mods"
set "SERVER_MODE=NO" 
set "SERVER_DIR=" 
set "DOWNLOAD_URL=https://github.com/enzonami/BitRust/archive/refs/heads/main.zip"
set "VERSION_URL=https://raw.githubusercontent.com/enzonami/BitRust/main/version.txt" 
set "ZIP_FILE=BitRust-main.zip"
set "SCRIPT=%~nx0"
set "LOG_FILE=%~dp0mod_update.log"
set "AUTO_MODE=NO"
set "PS_ERROR_FILE=%~dp0ps_error.txt"
set "USE_VERSION_CHECK=NO"  rem Set to YES once version.txt is added

if /i "%~1"=="/auto" set "AUTO_MODE=YES"

set "STEAM_WORKSHOP_DIR="
if exist "%PROGRAMFILES(x86)%\Steam\steamapps\workshop\content" set "STEAM_WORKSHOP_DIR=%PROGRAMFILES(x86)%\Steam\steamapps\workshop\content"
if exist "%PROGRAMFILES%\Steam\steamapps\workshop\content" set "STEAM_WORKSHOP_DIR=%PROGRAMFILES%\Steam\steamapps\workshop\content"
set "NECESSE_APP_ID=1169370" 

echo [%DATE% %TIME%] Script started. Auto mode: %AUTO_MODE% >> "%LOG_FILE%"

if "%AUTO_MODE%"=="NO" (
    cls
    echo %BRAND% - %GAME% Mod Installer %VERSION%
    echo Press any key to continue...
    pause >nul
)

if "%SERVER_MODE%"=="YES" (
    if not defined SERVER_DIR (
        echo [ERROR] SERVER_DIR not set! Edit the script.
        echo [%DATE% %TIME%] Error: SERVER_DIR not set. >> "%LOG_FILE%"
        pause
        exit /b
    )
    set "MOD_DIR=%SERVER_DIR%\mods"
)
if not exist "%MOD_DIR%" (
    mkdir "%MOD_DIR%" >nul 2>&1
    echo [INFO] Created mod folder: %MOD_DIR%
    echo [%DATE% %TIME%] Created mod folder. >> "%LOG_FILE%"
)

set "LOCAL_VERSION=unknown"
set "REMOTE_VERSION=update_needed"  rem Default to update
if "%USE_VERSION_CHECK%"=="YES" (
    if exist "%MOD_DIR%\version.txt" set /p LOCAL_VERSION<"%MOD_DIR%\version.txt"
    powershell -Command "$wc = New-Object System.Net.WebClient; try { $wc.DownloadFile('%VERSION_URL%', 'remote_version.txt') } catch { Write-Output $_.Exception.Message > '%PS_ERROR_FILE%' }" >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Failed to download remote version. Assuming update needed.
        type "%PS_ERROR_FILE%"
        echo [%DATE% %TIME%] Warning: Remote version download failed. See ps_error.txt. >> "%LOG_FILE%"
        type "%PS_ERROR_FILE%" >> "%LOG_FILE%"
        set "REMOTE_VERSION=update_needed"
    ) else if exist "remote_version.txt" (
        set /p REMOTE_VERSION<"remote_version.txt"
        del "remote_version.txt" >nul 2>&1
    )
    echo [INFO] Local version: !LOCAL_VERSION! Remote: !REMOTE_VERSION! >> "%LOG_FILE%"
)

if "%AUTO_MODE%"=="YES" (
    if "!LOCAL_VERSION!"=="!REMOTE_VERSION!" (
        echo [%DATE% %TIME%] No update needed. Exiting. >> "%LOG_FILE%"
        exit /b
    )
    goto install
)

:menu
cls
echo %BRAND% - %GAME% Mod Installer %VERSION%
echo.
echo Mod Folder: %MOD_DIR%
echo Local Version: !LOCAL_VERSION! Remote: !REMOTE_VERSION!
echo Steam Workshop: %STEAM_WORKSHOP_DIR%
echo.
echo [1] Install/Update Mods [2] Open Mod Folder [3] Clear Necesse Workshop [4] Exit
echo.
choice /c 1234 /n /m "Choose [1-4]: "
if errorlevel 4 goto goodbye
if errorlevel 3 goto clear_workshop
if errorlevel 2 goto openfolder
if errorlevel 1 goto install

:install
echo [INFO] Downloading latest mods from GitHub...
powershell -Command "$wc = New-Object System.Net.WebClient; try { $wc.DownloadFile('%DOWNLOAD_URL%', '%ZIP_FILE%') } catch { Write-Output $_.Exception.Message > '%PS_ERROR_FILE%' }" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Download failed! Check ps_error.txt.
    type "%PS_ERROR_FILE%"
    echo [%DATE% %TIME%] Error: Download failed. >> "%LOG_FILE%"
    type "%PS_ERROR_FILE%" >> "%LOG_FILE%"
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)
echo [INFO] Download complete. ZIP size: 
dir "%ZIP_FILE%" | findstr "%ZIP_FILE%"
echo Press any key to continue to unzip...
pause >nul

echo [INFO] Backing up old mods...
if exist "%MOD_DIR%\backup" rmdir /S /Q "%MOD_DIR%\backup" >nul 2>&1
mkdir "%MOD_DIR%\backup" >nul 2>&1
copy /Y "%MOD_DIR%\*.*" "%MOD_DIR%\backup\" >nul 2>&1

echo [INFO] Unzipping mods...
powershell -Command "try { Add-Type -AssemblyName System.IO.Compression.FileSystem; [IO.Compression.ZipFile]::ExtractToDirectory('%ZIP_FILE%', '.') } catch { Write-Output $_.Exception.Message > '%PS_ERROR_FILE%' }" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Unzip failed! Check ps_error.txt.
    type "%PS_ERROR_FILE%"
    echo [%DATE% %TIME%] Error: Unzip failed. >> "%LOG_FILE%"
    type "%PS_ERROR_FILE%" >> "%LOG_FILE%"
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)
del "%ZIP_FILE%" >nul 2>&1

echo [INFO] Moving mods to %MOD_DIR%...
if exist "BitRust-main\mods\*" (
    copy /Y "BitRust-main\mods\*.*" "%MOD_DIR%\" >nul 2>&1
    echo [OK] Mods installed from BitRust-main/mods
) else (
    echo [WARNING] No mods folder in ZIP. Copying all files...
    copy /Y "BitRust-main\*.*" "%MOD_DIR%\" >nul 2>&1
)
echo %REMOTE_VERSION% > "%MOD_DIR%\version.txt"
rmdir /S /Q "BitRust-main" >nul 2>&1

if "%SERVER_MODE%"=="YES" (
    echo [INFO] Restarting Necesse Server...
    taskkill /IM NecesseServer.exe /F >nul 2>&1 
    start "" "%SERVER_DIR%\NecesseServer.exe" 
)

echo =========================================
echo Installed latest mods! Version: !REMOTE_VERSION!
echo Restart %GAME% to load mods!
echo =========================================
echo [%DATE% %TIME%] Mods updated to !REMOTE_VERSION!. >> "%LOG_FILE%"
if "%AUTO_MODE%"=="NO" pause
goto menu

:clear_workshop
if not defined STEAM_WORKSHOP_DIR (
    echo [ERROR] Steam Workshop not found!
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)
echo [WARNING] This will DELETE Necesse Workshop mods only!
choice /c yn /n /m "Continue? [y/n]: "
if errorlevel 2 goto menu
echo [INFO] Clearing Necesse Workshop...
rmdir /S /Q "%STEAM_WORKSHOP_DIR%\%NECESSE_APP_ID%" >nul 2>&1
echo [OK] Necesse Workshop cleared!
echo [%DATE% %TIME%] Workshop cleared. >> "%LOG_FILE%"
if "%AUTO_MODE%"=="NO" pause
goto menu

:openfolder
explorer "%MOD_DIR%"
echo [INFO] Mod folder opened!
if "%AUTO_MODE%"=="NO" pause
goto menu

:goodbye
cls
echo Thanks for using %BRAND%!
echo Goodbye!
if "%AUTO_MODE%"=="NO" (
    echo Press any key to exit...
    pause >nul
)
echo [%DATE% %TIME%] Script ended. >> "%LOG_FILE%"
exit