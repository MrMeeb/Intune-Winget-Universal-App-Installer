$AppName = ''

$LOGROOT="${env:ProgramFiles}\CAW\IntuneLogs\$AppName"

Start-Transcript -path $LOGROOT\detect.ps1.log -append

Invoke-Webrequest -uri https://raw.githubusercontent.com/MrMeeb/Intune-Winget-Universal-App-Installer/refs/heads/main/Online/detect.ps1 -outfile detect.ps1
powershell.exe -executionpolicy bypass .\detect.ps1 -AppName $AppName