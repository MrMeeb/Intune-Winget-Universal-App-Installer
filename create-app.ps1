# Creates and uploads the Win32 app to Intune

# It is required to create an app registration to get a ClientID, since this module uses a now-disabled authentication method. See https://github.com/MSEndpointMgr/IntuneWin32App/issues/156#issuecomment-2190003235.
# Once the app registration is created and permissions are set, the ClientID can just be provided in the script. Editing of the ps1 as suggested is not required.

#Requires -Modules IntuneWin32App
$ErrorActionPreference = "Stop"

############################################################################

## Variables

# App details
$AppName = ""
$WingetAppName = ""
$AppDescription = ""
$AppPublisher = ""
$AppVersion = ""
$AppIcon = ""
$InstallExperience = "System" #System/User

# Assignment details
$RequiredAllDevices = $false
$RequiredAllUsers = $false
$AvailableAllDevices = $false
$AvailableAllUsers = $false

$RequiredGroups = @()
$AvailableGroups = @()
$ExcludeGroups = @()

# Intune Authentication options
$TenantID = "example.onmicrosoft.com"
$ClientID = ""

############################################################################

# No further customisation needed beyond this point

$SourceFolder = "$PSScriptRoot\Source"
$SetupFile = "install.cmd"
$OutputFolder = "$PSScriptRoot"

$action = "Add"

############################################################################

## Script starts

# Login to Intune
Write-Host "`nLogging in to Intune" -ForegroundColor Cyan
Connect-MSIntuneGraph -TenantID $TenantID -ClientID $ClientID -Refresh

# Winget ID (for creating a dependency)
$WingetID = $(Get-IntuneWin32App -DisplayName "WinGet").id

# Search for application of same name
Write-Host "`nSearching for an existing app called $AppName" -ForegroundColor Cyan
# App ID, for discovery
$AppID = $(Get-IntuneWin32App -DisplayName $AppName)

if ($AppID.id.Length -gt 0 ) {
    Write-Host "`nThere is already an app called $AppName in this Intune tenant." -ForegroundColor Red
    $response = Read-Host "Would you like to update $AppName with the new configuration? Note that not every parameter can be updated (y/n)"
    if ($response -eq "y") {
        Write-Host "`nUpdating $AppName in Intune" -ForegroundColor Yellow
        $action = "Update"
        
    } elseif ($response -eq "n") {
        Write-Host "`nTaking no further action."
        exit 1
    } else {
        Write-Host "`nResponse not recognised - exiting."
        exit 1
    }
}

# Prepare the detection script
Write-Host "Configuring the detection script to detect $WingetAppName" -ForegroundColor Cyan
(Get-Content $PSScriptRoot\Detection-Sample\detect.ps1).Replace('Sample.Sample', $WingetAppName) | Set-Content $PSScriptRoot\Detection-Sample\detect.ps1

# Build the intunewin package
Write-Host "Building the .intunewin Win32 package" -ForegroundColor Cyan
New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $SetupFile -OutputFolder $OutputFolder -Force
$IntuneWinFile = "$PSScriptRoot\install.intunewin"

# Get the icon for the app
if ($AppIcon.Contains("https://")) {
    Write-Host "`nAppIcon is a URL, downloading image to working directory" -ForegroundColor Cyan
    $Extension = $($AppIcon.Substring($AppIcon.Length -3))
    Invoke-WebRequest -Uri $AppIcon -OutFile $PSScriptRoot\Assets\icon.$Extension
    $AppIcon = "$PSScriptRoot\Assets\icon.$Extension"
    Write-Host "Icon downloaded to $AppIcon"
}

$Icon = New-IntuneWin32AppIcon -FilePath $AppIcon

# Create requirement rule for all platforms and Windows 10 20H2
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "All" -MinimumSupportedWindowsRelease "W11_21H2"

# Create PowerShell script detection rule
$DetectionScriptFile = "$PSScriptRoot\Detection-Sample\detect.ps1"
$DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $DetectionScriptFile -EnforceSignatureCheck $false -RunAs32Bit $false

# Add new EXE Win32 app
$InstallCommandLine = "`"%systemroot%\sysnative\cmd.exe`" /c `"install.cmd`" install $WingetAppName"
$UninstallCommandLine = "`"%systemroot%\sysnative\cmd.exe`" /c `"install.cmd`" uninstall $WingetAppName"

if ($action.Contains("Add")) {
    Write-Host "`nUploading $AppName to Intune"  -ForegroundColor Cyan

    $AppID = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $AppName -Description $AppDescription -Publisher $AppPublisher -AppVersion $AppVersion -InstallExperience $InstallExperience -AllowAvailableUninstall -Icon $Icon -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Verbose
    
    # Configure the dependency for WinGet to ensure its installed prior to this app
    Write-Host "`nConfiguring dependency on Winget" -ForegroundColor Cyan
    $WingetDependecy = New-IntuneWin32AppDependency -ID $WingetID -DependencyType AutoInstall
    Add-IntuneWin32AppDependency -ID $AppID.id -Dependency $WingetDependecy
} elseif ($action.Contains("Update")) {
    Write-Host "`nUpdating $AppName with the latest configuration" -ForegroundColor Cyan

    Update-IntuneWin32AppPackageFile -ID $AppID.id -FilePath $IntuneWinFile -Verbose
    Set-IntuneWin32App -ID $AppID.id -DisplayName $AppName -Description $AppDescription -Publisher $AppPublisher -AppVersion $AppVersion -AllowAvailableUninstall $true -Verbose

}

# Configure assigments 
Write-Host "`nConfiguring assignments" -ForegroundColor Cyan

## Boolean options
if ($RequiredAllDevices) {
    Write-Host "`nMarking as required for all devices" -ForegroundColor Yellow
    Add-IntuneWin32AppAssignmentAllDevices -ID $AppID.id -Intent required
}
if ($RequiredAllUsers) {
    Write-Host "`nMarking as required for all users" -ForegroundColor Yellow
    Add-IntuneWin32AppAssignmentAllUsers -ID $AppID.id -Intent required
}
if ($AvailableAllDevices) {
    Write-Host "`nMarking as available for all devices" -ForegroundColor Yellow
    Add-IntuneWin32AppAssignmentAllDevices -ID $AppID.id -Intent available
}
if ($AvailableAllUsers) {
    Write-Host "`nMarking as available for all users" -ForegroundColor Yellow
    Add-IntuneWin32AppAssignmentAllUsers -ID $AppID.id -Intent available
}

## Array iteration
if ($RequiredGroups.count -gt 0) {

    foreach ( $group in $RequiredGroups )
    {
        Write-Host "Marking $group as required" -ForegroundColor Yellow
        Add-IntuneWin32AppAssignmentGroup -ID $AppID.id -Include -GroupID $group -Intent required
    }

}

if ($AvailableGroups.count -gt 0) {

    foreach ( $group in $AvailableGroups )
    {
        Write-Host "Marking $group as available" -ForegroundColor Yellow
        Add-IntuneWin32AppAssignmentGroup -ID $AppID.id -Include -GroupID $group -Intent available
    }

}

if ($ExcludeGroups.count -gt 0) {

    foreach ( $group in $ExcludeGroups )
    {
        Write-Host "Marking $group as excluded" -ForegroundColor Yellow
        Add-IntuneWin32AppAssignmentGroup -ID $AppID.id -Exclude -GroupID $group
    }

}

Write-Host "`nDone configuring assigments" -ForegroundColor Cyan

Write-Host "`nSuccessfully uploaded $AppName to Intune"  -ForegroundColor Green