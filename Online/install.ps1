param(
    [Parameter(Mandatory)]
    [string]$Action,
    [Parameter(Mandatory)]
	[string]$AppName
 )

# Set logging dir
$LOGROOT="${env:ProgramFiles}\CAW\IntuneLogs\$AppName"

Start-Transcript -path $LOGROOT\install.ps1.log -append

# Locate WinGet
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($ResolveWingetPath){
		$WingetPath = $ResolveWingetPath[-1].Path
}

if ($WingetPath.length -lt 10){
	Write-Error -Message "Winget not found." -Category OperationStopped
	exit
}

$WingetPath = Split-Path -Path $WingetPath -Parent

switch ($Action){
    "install" {
		try {
			Set-Location $WingetPath
			.\winget.exe install --exact --id $AppName --silent --accept-package-agreements --accept-source-agreements
		}
		catch {
			Write-Error -Message "Error happened during installation." -Category OperationStopped
		}
	}
    "uninstall" {
		try {
			Set-Location $WingetPath
			.\winget.exe uninstall --exact --id $AppName --silent
			.\winget.exe export --ignore-warnings --output $LOGROOT\$AppName.json
		}
		catch {
			Write-Error -Message "Error happened during uninstallation." -Category OperationStopped
    	}
	}
}