<#
.SYNOPSIS
    Symlink the Mods and Public folder
.DESCRIPTION
    Creates symbolic links for the Mods and Public folders to the Game's Data directory.
    This allows changes made here to be immediately reflected in the game.
    This also allows you to make use of the power of git to switch between projects seamlessly
    (using branches) without having to touch the Game's Data directory every time.
.EXAMPLE
    . .\Script\Symlink-GameDataFolder.ps1
    Run the script to symlink the Mods and Public folder to the Game's Data directory.
.EXAMPLE
    . .\Script\Symlink-GameDataFolder.ps1 -WhatIf
    Perform a dry-run to see what modifications the script will make.
.EXAMPLE
    . .\Script\Symlink-GameDataFolder.ps1 -BG3Path "C:\Games\Baldurs Gate 3"
    Run the script by specifying the path to the game's folder
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    # Path to the Baldurs Gate 3 folder
    [ValidateScript({ Test-Path -Path $_ })]
    [string] $BG3Path = $Env:BG3_PATH,

    # Name of the Mod
    [ValidateNotNullOrEmpty()]
    [string] $ModName = "S7_ProvingGrounds",

    # UUID of the Mod
    [ValidatePattern('^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')]
    [string] $ModUUID = "07d5faee-0c54-4787-8b39-e3f45a52145d"
)

# Check the game folder path
if (!(Test-Path -Path (Join-Path $BG3Path "bin\bg3.exe"))) {
    throw "Invalid Path: $BG3Path. Please provide the path to the Baldurs Gate 3 folder"
}

# Check if the script is running with administrator privilege
# Get the ID and security principal of the current user account
$MyIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$MyPrincipal = New-Object System.Security.Principal.WindowsPrincipal($MyIdentity)
# Check to see if we are currently running in "Administrator" mode
if (!$MyPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Need Administrator Mode to create symbolic links! Re-run this script with administrator privileges"
}

# Constants
$ModID = "$($ModName)_$($ModUUID)"

# Determine paths
$GameDataFolder = Join-Path $BG3Path "Data"
$ModsFolder = Join-Path $GameDataFolder "Mods"
$PublicFolder = Join-Path $GameDataFolder "Public"

# Create Mods and Public folders if they do not exist in the Game's Data folder
if (!(Test-Path -Path $ModsFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $ModsFolder
}
if (!(Test-Path -Path $PublicFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $PublicFolder
}

# Create Symbolic Links
New-Item -ItemType SymbolicLink -Path (Join-Path $ModsFolder $ModID) -Target (Join-Path $PSScriptRoot ".." $ModName "Mods" $ModID)
New-Item -ItemType SymbolicLink -Path (Join-Path $PublicFolder $ModID) -Target (Join-Path $PSScriptRoot ".." $ModName "Public" $ModID)

# Log success or any additional information here
Write-Host "✅ Symlinks for Mods and Public folders successfully created in Baldur's Gate 3 Data folder"
