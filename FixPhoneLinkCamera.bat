@echo off
setlocal enabledelayedexpansion

:: 1. Automatically request Admin rights
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>&1 || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:menu
cls
echo ===================================================
echo           PHONE LINK CONNECTION REPAIR
echo ===================================================
echo.
echo This script will perform the following actions:
echo   1) Repair the Phone Link App (via PowerShell)
echo   2) Restart the Bluetooth User Support Service
echo   3) Restart the Phone Service
echo.
echo Note: These steps can also be performed manually 
echo in Windows Settings and the Services manager.
echo.

:choice
set /P c=Do you want to proceed? [Y/N]: 
if /I "%c%" EQU "Y" goto :proceed
if /I "%c%" EQU "N" goto :quit
echo Invalid input, please type Y or N.
goto :choice

:proceed
echo.
echo [1/3] Closing Phone Link and Repairing the App...
taskkill /f /im PhoneExperienceHost.exe >nul 2>&1
powershell -command "Get-AppxPackage *Microsoft.YourPhone* | Reset-AppxPackage"
echo [OK] Phone Link app repair complete.

echo.
echo [2/3] Searching for Bluetooth User Support Service...
:: Since the service name is dynamic and varies from different machines
for /f "tokens=1" %%a in ('wmic service where "name like 'BluetoothUserService_%%'" get name ^| findstr /i "BluetoothUserService"') do set "BT_SERVICE=%%a"

if defined BT_SERVICE (
    echo Restarting %BT_SERVICE%...
    net stop %BT_SERVICE% /y >nul 2>&1
    net start %BT_SERVICE%
    echo [OK] Bluetooth Service restarted.
) else (
    echo [!] Could not find a dynamic Bluetooth User Support Service.
)

echo.
echo [3/3] Restarting Phone Service...
net stop PhoneSvc /y >nul 2>&1
net start PhoneSvc
echo [OK] Phone Service restarted.

echo.
echo ===================================================
echo DONE! Please try opening Phone Link now.
echo ===================================================
echo This window will close automatically in 5 seconds...
timeout /t 5 >nul
exit

:quit
echo.
echo Operation cancelled by user. 
echo Closing in 3 seconds...
timeout /t 3 >nul
exit