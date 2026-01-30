@echo off
:: Automatically request Admin rights
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>&1 || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

echo ===========================================
echo   Fixing Phone Link Camera Connection...
echo ===========================================

:: 1. Restart Phone Service
echo Stopping Phone Service...
net stop PhoneSvc /y
echo Starting Phone Service...
net start PhoneSvc
echo Phone service started

:: 2. Restart Bluetooth User Support Service
echo Searching for Bluetooth User Support Service...
:: Searching for the specific name, since the names are dynamic
for /f "tokens=1" %%a in ('wmic service where "name like 'BluetoothUserService_%%'" get name ^| findstr /i "BluetoothUserService"') do set "BT_SERVICE=%%a"

if defined BT_SERVICE (
    echo Stopping %BT_SERVICE%...
    net stop %BT_SERVICE% /y
    echo Starting %BT_SERVICE%...
    net start %BT_SERVICE%
) else (
    echo [!] Could not find Bluetooth User Support Service.
)

:: Repair teh app
::Kill the app process first
echo Closing Phone Link processes...
taskkill /f /im PhoneExperienceHost.exe >nul 2>&1
echo Triggering App Repair for Phone Link...
powershell -command "Get-AppxPackage *Microsoft.YourPhone* | Reset-AppxPackage"
echo Phone Link app repair complete

echo.
echo All services have been restarted and the Phone Link app has been repaired. Try opening Phone Link now!
pause