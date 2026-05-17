@echo off
setlocal

:: ==========================================
:: CHANGE THESE TO YOUR ACTUAL GITHUB RAW LINKS
:: ==========================================
set "SetupURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/setup.exe"
set "XmlURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/Configuration.xml"
:: ==========================================

echo Creating temporary workspace...
set "WorkDir=%SystemDrive%\Office2024Temp"
if not exist "%WorkDir%" mkdir "%WorkDir%"

echo Downloading components from GitHub repository...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%SetupURL%' -OutFile '%WorkDir%\setup.exe'"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%XmlURL%' -OutFile '%WorkDir%\configuration.xml'"

echo Launching Office LTSC 2024 Installation...
echo The Microsoft installer UI will appear shortly.

:: Bypass network origin warnings since it's local now
set SEE_MASK_NOZONECHECKS=1

:: Run the setup
cd /d "%WorkDir%"
setup.exe /configure configuration.xml

:: Restore warning settings
set SEE_MASK_NOZONECHECKS=

echo.
echo Cleaning up temporary installation files...
cd /
rmdir /s /q "%WorkDir%"

echo Deployment complete.
pause