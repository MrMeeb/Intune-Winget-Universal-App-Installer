#Requires -Modules IntuneWin32App

$SourceFolder = "$PSScriptRoot\Source"
$SetupFile = "install.cmd"
$OutputFolder = "$PSScriptRoot"

# Build the intunewin package
Write-Host "Building the .intunewin Win32 package" -ForegroundColor Cyan
New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $SetupFile -OutputFolder $OutputFolder -Force