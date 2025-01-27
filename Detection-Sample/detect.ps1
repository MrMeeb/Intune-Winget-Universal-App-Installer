$AppName = 'Obsidian.Obsidian'

$TEMP = [System.Environment]::GetEnvironmentVariable('TEMP','User')
Write-Host $TEMP
$LOGROOT="${env:ProgramFiles}\CAW\IntuneLogs\$AppName"

Start-Transcript -path $LOGROOT\detect.ps1.log -append

Invoke-Webrequest -uri https://raw.githubusercontent.com/MrMeeb/Intune-Winget-Universal-App-Installer/refs/heads/develop/Online/detect.ps1 -outfile "$TEMP\detect-$AppName.ps1"
powershell.exe -executionpolicy bypass "$TEMP\detect-$AppName.ps1" -AppName $AppName | Out-Host
# Detect exit code of child script and exit with it if it isn't 0
if ($LastExitCode -ne 0)
{
    Write-Output "An error occured in the child process"
    exit $LastExitCode
}

Stop-Transcript
