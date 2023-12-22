<#
.SYNOPSIS
    Cleans the Baldurs Gate 3 Game Data folder
.DESCRIPTION
    Removes the Mods and Public from the Baldurs Gate 3 Data folder
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

# Determine paths
$GameDataFolder = Join-Path $Path "Data"
$ModsFolder = Join-Path $GameDataFolder "Mods"
$PublicFolder = Join-Path $GameDataFolder "Public"

# Clean the folder
$ModsFolder, $PublicFolder | Remove-Item
