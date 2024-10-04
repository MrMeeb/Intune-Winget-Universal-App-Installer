:: Install command in Intune needs to be "%systemroot%\sysnative\cmd.exe" /c "install.cmd"
:: This is to launch this script in a 64bit process
:: Source: https://call4cloud.nl/2021/05/sysnative-64-bit-ime-intune/ Option 2

:: %1 = actions (install|uninstall)
:: %2 = app name (7zip.7zip)

@echo off

set ACTION=%1
set APP=%2

:: Make logging dir
set LOGROOT="%ProgramFiles%\CAW\IntuneLogs\%2"
if not exist %LOGROOT% mkdir %LOGROOT%
call :LOG > %LOGROOT%\install.cmd.log

:: Halt script running after running the :LOG section
goto :eof

:LOG
echo "Action is %ACTION%"
echo "App is %APP%"
whoami
icacls %LOGROOT% /grant:r "Users":F
echo "Downloading install.ps1 script"
Powershell.exe Invoke-Webrequest -uri https://raw.githubusercontent.com/MrMeeb/intune-winget-universal-installer/refs/heads/main/Online/install.ps1 -outfile install.ps1
Powershell.exe -ExecutionPolicy ByPass -File ".\install.ps1" "%ACTION%" "%APP%"