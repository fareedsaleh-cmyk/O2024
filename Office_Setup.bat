@echo off
setlocal
:: ==========================================
:: AUTOMATIC ADMINISTRATIVE ELEVATION
:: ==========================================
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv%batchName%.vbs"
setlocal EnableDelayedExpansion
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )
:getPrivileges
if '%1'=='ELEV' (echo ELEVATION FAILURE & shift & goto gotPrivileges)
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "" >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& " " ^& strArg >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
del "%vbsGetPrivileges%" 2>nul
exit /B
:gotPrivileges
setlocal & cd /d %~dp0
:: ==========================================
:: CONFIGURATION
:: ==========================================
set "SetupURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/setup.exe"
set "XmlURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/Configuration.xml"
set "WorkDir=%SystemDrive%\Office2024Temp"
set "LogFile=%WorkDir%\install_log.txt"
:: ==========================================

:: Log start time
echo ==========================================
echo  Office LTSC 2024 Deployment Script
echo ==========================================
echo.

:: Check internet connectivity before downloading
echo Checking internet connectivity...
ping -n 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    echo ERROR: No internet connection detected. Cannot download files.
    pause
    exit /b 1
)
echo Internet connection OK.
echo.

:: Create workspace
echo Creating temporary workspace at %WorkDir%...
if not exist "%WorkDir%" mkdir "%WorkDir%"

:: Start logging
echo Office 2024 Deployment Log - %DATE% %TIME% > "%LogFile%"
echo. >> "%LogFile%"

:: Download setup.exe with progress and retry
echo Downloading setup.exe...
curl -L --retry 3 --retry-delay 5 -o "%WorkDir%\setup.exe" "%SetupURL%"
if not exist "%WorkDir%\setup.exe" (
    echo ERROR: setup.exe failed to download. >> "%LogFile%"
    echo.
    echo ERROR: setup.exe failed to download. Check your internet connection or URL.
    pause
    exit /b 1
)
echo setup.exe downloaded successfully. >> "%LogFile%"
echo setup.exe downloaded OK.

:: Download configuration.xml with retry
echo Downloading configuration.xml...
curl -L --retry 3 --retry-delay 5 -o "%WorkDir%\configuration.xml" "%XmlURL%"
if not exist "%WorkDir%\configuration.xml" (
    echo ERROR: configuration.xml failed to download. >> "%LogFile%"
    echo.
    echo ERROR: configuration.xml failed to download. Check your internet connection or URL.
    pause
    exit /b 1
)
echo configuration.xml downloaded successfully. >> "%LogFile%"
echo configuration.xml downloaded OK.
echo.

:: Verify setup.exe is a valid size (catches HTML error pages saved as the file)
for %%A in ("%WorkDir%\setup.exe") do set "FileSize=%%~zA"
if %FileSize% LSS 100000 (
    echo ERROR: setup.exe appears too small - likely a download error. >> "%LogFile%"
    echo ERROR: setup.exe appears too small ^(%FileSize% bytes^). The download may have failed silently.
    pause
    exit /b 1
)

:: Launch installation
echo Launching Office LTSC 2024 installation...
echo Installation started at %TIME% >> "%LogFile%"
set SEE_MASK_NOZONECHECKS=1
cd /d "%WorkDir%"
setup.exe /configure configuration.xml
set "InstallResult=%errorlevel%"
set SEE_MASK_NOZONECHECKS=

:: Check installer exit code
echo.
if %InstallResult% == 0 (
    echo Installation completed successfully at %TIME%. >> "%LogFile%"
    echo ==========================================
    echo  Installation completed successfully.
    echo  Log saved to: %LogFile%
    echo ==========================================
) else (
    echo Installation exited with code %InstallResult% at %TIME%. >> "%LogFile%"
    echo ==========================================
    echo  Installation finished with exit code: %InstallResult%
    echo  This may indicate an error. Check the log:
    echo  %LogFile%
    echo ==========================================
)
echo.
pause
