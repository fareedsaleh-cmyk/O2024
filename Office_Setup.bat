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
:: ==========================================
:: CHANGE THESE TO YOUR ACTUAL GITHUB RAW LINKS
:: ==========================================
set "SetupURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/setup.exe"
set "XmlURL=https://raw.githubusercontent.com/fareedsaleh-cmyk/O2024/refs/heads/main/Configuration.xml"
:: ==========================================
echo Creating temporary workspace...
set "WorkDir=%SystemDrive%\Office2024Temp"
if not exist "%WorkDir%" mkdir "%WorkDir%"
echo.
echo Downloading components from GitHub via curl...
:: Using native curl to bypass broken Windows BITS services and PowerShell blocks
curl -L -s -o "%WorkDir%\setup.exe" "%SetupURL%"
curl -L -s -o "%WorkDir%\configuration.xml" "%XmlURL%"
if not exist "%WorkDir%\setup.exe" (
    echo.
    echo ERROR: setup.exe failed to download via curl.
    pause
    exit /b 1
)
echo.
echo Launching Office LTSC 2024 Installation...
echo The Microsoft installer UI will appear shortly.
set SEE_MASK_NOZONECHECKS=1
cd /d "%WorkDir%"
setup.exe /configure configuration.xml
set SEE_MASK_NOZONECHECKS=
echo.
echo Cleaning up temporary installation files...
cd /
rmdir /s /q "%WorkDir%"
echo Deployment complete.
pause
