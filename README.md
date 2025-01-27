# WinGet Universal App Installer

Enables the automatic installation of a WinGet package. Developed for use with Intune. Requires WinGet to be installed prior to app installation.

Pulls the actual install and detection scripts from an online repo using wrappers included in the intunewin and added to Intune. Makes iteration of the install and detection process much easier at scale.

Uses the `IntuneWin32App` PS module for automatic intunewin creation and upload to Intune.

Complete all fields in `create-app.ps1` before trying to upload an app.

> [!IMPORTANT]
> `IntuneWin32App` uses a since-retired authentication method for accessing Intune. This is easily overcome by creating your own App Registration and providing your own `ClientID`, as is laid out in `create-app.ps1`. See the comment on [MSEndpointMgr/ntuneWin32App#156](https://github.com/MSEndpointMgr/IntuneWin32App/issues/156#issuecomment-2190003235) for details on the permissions. The actual script modification is, in my experience, not required.
