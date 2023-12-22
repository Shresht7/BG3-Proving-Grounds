<#
.SYNOPSIS
    Cleans the Baldurs Gate 3 Game Data folder
.DESCRIPTION
    Removes the Mods and Public from the Baldurs Gate 3 Data folder
.EXAMPLE
    . .\Script\Clean-GameDataFolder.ps1
    Run the script to remove the Mods and Public folders
.EXAMPLE
    . .\Script\Clean-GameDataFolder.ps1 -WhatIf
    Perform a dry-run to see what modifications the script will make.
.EXAMPLE
    . .\Script\Clean-GameDataFolder.ps1 -BG3Path "C:\Games\Baldurs Gate 3"
    Run the script by specifying the game's folder
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    # Path to the Baldurs Gate 3 folder
    [ValidateScript({ Test-Path -Path $_ })]
    [string] $BG3Path = $Env:BG3_PATH
)

# Check path
if (!(Test-Path -Path (Join-Path $BG3Path "bin\bg3.exe"))) {
    throw "Invalid Path: $BG3Path. Please provide the path to the Baldurs Gate 3 folder"
}

# Determine paths
$GameDataFolder = Join-Path $BG3Path "Data"
$ModsFolder = Join-Path $GameDataFolder "Mods"
$PublicFolder = Join-Path $GameDataFolder "Public"

# Clean the folder
$ModsFolder, $PublicFolder | Where-Object { Test-Path -Path $_ } | Remove-Item
