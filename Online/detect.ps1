# Set logging dir

param(
    [Parameter(Mandatory)]
    [string]$AppName
)

Start-Transcript -path $LOGROOT\detect.ps1.log -append

if ( $(whoami) -like "*system*" ) {

    Write-Host "Running as System"

    $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
        $WingetPath = $ResolveWingetPath[-1].Path
    }
    
    if ($AppName.length -lt 1){
        Write-host "AppName is not set"
        exit 1
    }
    
    $WingetPath = Split-Path -Path $WingetPath -Parent
    Set-Location $WinGetPath
    $CheckInstalled = $(.\winget.exe list --id $AppName --accept-source-agreements)
    if ($CheckInstalled -like "*$AppName*")
        { 
            Write-host "Found $AppName"
    } else {
        whoami
        Write-host "$AppName not found"
        exit 1
    }

} else {

    Write-Host "Running as User, attempting to use winget from path"
    $CheckInstalled = $(winget list --id $AppName --accept-source-agreements)

    if ($CheckInstalled -like "*$AppName*") { 
            
        Write-host "Found $AppName"

    } else {
        
        Write-host "$AppName not found"
        exit 1
        
    }

}
