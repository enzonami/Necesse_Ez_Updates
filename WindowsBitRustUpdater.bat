@echo off
setlocal enabledelayedexpansion
rem =============================================
rem BitRust Network - Necesse Mod Installer
rem AUTO-DOWNLOADS & CLEAN INSTALL
rem NO version.txt | Preserves modlist.data | Torch detection
rem =============================================
set "BRAND=BitRust Network"
set "GAME=Necesse"
set "VERSION=v1.0"
set "MOD_DIR=%APPDATA%\Necesse\mods"
set "DOWNLOAD_URL=https://github.com/enzonami/BitRust_Network_Factions/archive/refs/heads/main.zip"
set "ZIP_FILE=BitRust_Network_Factions-main.zip"
set "LOG_FILE=%~dp0mod_update.log"
set "AUTO_MODE=NO"
set "PS_ERROR_FILE=%~dp0ps_error.txt"

if /i "%~1"=="/auto" set "AUTO_MODE=YES"

set "STEAM_WORKSHOP_DIR="
if exist "%PROGRAMFILES(x86)%\Steam\steamapps\workshop\content" set "STEAM_WORKSHOP_DIR=%PROGRAMFILES(x86)%\Steam\steamapps\workshop\content"
if exist "%PROGRAMFILES%\Steam\steamapps\workshop\content" set "STEAM_WORKSHOP_DIR=%PROGRAMFILES%\Steam\steamapps\workshop\content"
set "NECESSE_APP_ID=1169370"

echo [%DATE% %TIME%] Script started. Auto: %AUTO_MODE% >> "%LOG_FILE%"

if "%AUTO_MODE%"=="NO" (
    cls
    echo %BRAND% - %GAME% Mod Installer %VERSION%
    echo Press any key to continue...
    pause >nul
)

rem --- Create mod folder if missing ---
if not exist "%MOD_DIR%" (
    mkdir "%MOD_DIR%" >nul 2>&1
    echo [INFO] Created mod folder: %MOD_DIR% >> "%LOG_FILE%"
)

if "%AUTO_MODE%"=="YES" goto install

:menu
cls
echo %BRAND% - %GAME% Mod Installer %VERSION%
echo.
echo Mod Folder: %MOD_DIR%
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
    echo [ERROR] Download failed! See ps_error.txt
    type "%PS_ERROR_FILE%"
    echo [%DATE% %TIME%] Download failed >> "%LOG_FILE%"
    type "%PS_ERROR_FILE%" >> "%LOG_FILE%"
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)

echo [INFO] Download complete. Size:
dir "%ZIP_FILE%" | findstr "%ZIP_FILE%"

if "%AUTO_MODE%"=="NO" (
    echo Press any key to unzip...
    pause >nul
)

rem --- Backup current mods (including modlist.data) ---
echo [INFO] Backing up current mods (including modlist.data)...
if exist "%MOD_DIR%\backup" rmdir /S /Q "%MOD_DIR%\backup" >nul 2>&1
mkdir "%MOD_DIR%\backup" >nul 2>&1
xcopy /Y /Q "%MOD_DIR%\*.*" "%MOD_DIR%\backup\" >nul 2>&1

rem --- Unzip new files ---
echo [INFO] Unzipping archive...
powershell -Command "try { Add-Type -AssemblyName System.IO.Compression.FileSystem; [IO.Compression.ZipFile]::ExtractToDirectory('%ZIP_FILE%', '.') } catch { Write-Output $_.Exception.Message > '%PS_ERROR_FILE%' }" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Unzip failed! See ps_error.txt
    type "%PS_ERROR_FILE%"
    echo [%DATE% %TIME%] Unzip failed >> "%LOG_FILE%"
    type "%PS_ERROR_FILE%" >> "%LOG_FILE%"
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)
del "%ZIP_FILE%" >nul 2>&1

set "EXTRACTED_DIR=BitRust_Network_Factions-main"
if not exist "%EXTRACTED_DIR%" (
    echo [ERROR] Extracted folder '%EXTRACTED_DIR%' not found!
    echo [DEBUG] Contents:
    dir /b
    echo [%DATE% %TIME%] Extracted folder missing >> "%LOG_FILE%"
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)

rem --- Count .jar files and detect torch ---
set "JAR_COUNT=0"
set "TORCH_FOUND=NO"
for %%f in ("%EXTRACTED_DIR%\*.jar") do (
    set /a JAR_COUNT+=1
    echo %%~nxf | findstr /i "torch" >nul && set "TORCH_FOUND=YES"
)

if %JAR_COUNT% equ 0 (
    echo [ERROR] No .jar files found in repo!
    echo [DEBUG] Files in %EXTRACTED_DIR%:
    dir "%EXTRACTED_DIR%" /b
    echo [%DATE% %TIME%] No JARs in repo >> "%LOG_FILE%"
    rmdir /S /Q "%EXTRACTED_DIR%" >nul 2>&1
    if "%AUTO_MODE%"=="NO" pause
    goto menu
)

rem --- CLEAN INSTALL: Delete everything except backup ---
echo [INFO] Performing clean install - removing ALL files in '%MOD_DIR%'...
rmdir /S /Q "%MOD_DIR%" >nul 2>&1
mkdir "%MOD_DIR%" >nul 2>&1

rem --- Restore modlist.data from backup (if it existed) ---
if exist "%MOD_DIR%\backup\modlist.data" (
    copy /Y "%MOD_DIR%\backup\modlist.data" "%MOD_DIR%\modlist.data" >nul
    echo [OK] Restored modlist.data
) else (
    echo [INFO] No modlist.data in backup - creating empty one
    echo. > "%MOD_DIR%\modlist.data"
)

rem --- Copy new .jar mods ---
echo [INFO] Installing %JAR_COUNT% new .jar mod(s)...
for %%f in ("%EXTRACTED_DIR%\*.jar") do (
    copy /Y "%%f" "%MOD_DIR%\" >nul 2>&1
)

echo [OK] Clean install complete: %JAR_COUNT% mod(s)
if "%TORCH_FOUND%"=="YES" (
    echo    Checkmark torch mod installed!
) else (
    echo    Cross torch mod missing
)

rem --- Cleanup ---
rmdir /S /Q "%EXTRACTED_DIR%" >nul 2>&1

echo =========================================
echo Installed latest mods!
echo Restart %GAME% to load!
echo =========================================
echo [%DATE% %TIME%] Clean install: %JAR_COUNT% JARs. Torch: %TORCH_FOUND%. modlist.data: preserved. >> "%LOG_FILE%"

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
echo [OK] Workshop cleared!
echo [%DATE% %TIME%] Workshop cleared >> "%LOG_FILE%"
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
exit /b
