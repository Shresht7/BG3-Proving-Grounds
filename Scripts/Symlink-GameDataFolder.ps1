<#
.SYNOPSIS
    Symlink the Mods and Public folder
.DESCRIPTION
    Creates symbolic links for the Mods and Public folders to the Game's Data directory.
    This allows changes made here to be immediately reflected in the game.
#>
param (
    # Path to the Baldurs Gate 3 folder
    [ValidateScript({ Test-Path -Path $Path })]
    [string] $PATH = $Env:BG3_PATH
)

# Check path
if (!(Test-Path -Path (Join-Path $Path "bin\bg3.exe"))) {
    throw "Invalid Path: $PATH. Please provide the path to the Baldurs Gate 3 folder"
}

# Check if the script is running with administrator privilege
# Get the ID and security principal of the current user account
$MyIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$MyPrincipal = New-Object System.Security.Principal.WindowsPrincipal($MyIdentity)
# Check to see if we are currently running in "Administrator" mode
if (!$MyPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Symlinking required you to be in administrator mode!"
}

# Constants
$ModName = "S7_ProvingGrounds"
$ModUUID = "07d5faee-0c54-4787-8b39-e3f45a52145d"
$ModID = "$($ModName)_$($ModUUID)"

# Determine paths
$GameDataFolder = Join-Path $Path "Data"
$ModsFolder = Join-Path $GameDataFolder "Mods"
$PublicFolder = Join-Path $GameDataFolder "Public"

# If the Mods and Public folders do no exist in the game directory, create them
if (!(Test-Path -Path $ModsFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $ModsFolder
}
if (!(Test-Path -Path $PublicFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $PublicFolder
}

# Create Symbolic Links
New-Item -ItemType SymbolicLink -Path (Join-Path $ModsFolder $ModID) -Target (Join-Path $PSScriptRoot ".." $ModName "Mods" $ModID)
New-Item -ItemType SymbolicLink -Path (Join-Path $PublicFolder $ModID) -Target (Join-Path $PSScriptRoot ".." $ModName "Public" $ModID)
