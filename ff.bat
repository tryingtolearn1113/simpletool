@echo off
setlocal EnableExtensions

title Firefox + AdGuard + Dark Reader

set "BASE=%LOCALAPPDATA%\Firefox-Library"
set "FF=%BASE%\Firefox\firefox.exe"
set "DIST=%BASE%\Firefox\distribution"
set "POLICY=%DIST%\policies.json"
set "INSTALLER=%TEMP%\FirefoxSetup.exe"

echo.
echo ==========================================
echo   Firefox + AdGuard + Dark Reader
echo ==========================================
echo.

REM Download Firefox if needed
if not exist "%FF%" (
    echo [1/4] Downloading Firefox...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest 'https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US' -OutFile '%INSTALLER%'"

    if not exist "%INSTALLER%" (
        echo ERROR: Firefox download failed.
        pause
        exit /b 1
    )

    echo [2/4] Installing Firefox...

    if not exist "%BASE%" mkdir "%BASE%"

    start /wait "" "%INSTALLER%" /S /InstallDirectoryPath="%BASE%\Firefox"

    del /q "%INSTALLER%" 2>nul
)

if not exist "%FF%" (
    echo ERROR: Firefox was not found.
    pause
    exit /b 1
)

REM Create policy
echo [3/4] Configuring extensions...

if not exist "%DIST%" mkdir "%DIST%"

> "%POLICY%" echo {
>>"%POLICY%" echo   "policies": {
>>"%POLICY%" echo     "ExtensionSettings": {
>>"%POLICY%" echo       "adguardadblocker@adguard.com": {
>>"%POLICY%" echo         "installation_mode": "force_installed",
>>"%POLICY%" echo         "install_url": "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi",
>>"%POLICY%" echo         "private_browsing": true
>>"%POLICY%" echo       },
>>"%POLICY%" echo       "addon@darkreader.org": {
>>"%POLICY%" echo         "installation_mode": "force_installed",
>>"%POLICY%" echo         "install_url": "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi",
>>"%POLICY%" echo         "private_browsing": true
>>"%POLICY%" echo       }
>>"%POLICY%" echo     }
>>"%POLICY%" echo   }
>>"%POLICY%" echo }

REM Close existing Firefox
taskkill /F /IM firefox.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [4/4] Starting Firefox...

start "" "%FF%" -private-window "https://www.google.com"

exit /b 0