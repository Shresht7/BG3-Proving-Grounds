<#
.SYNOPSIS
    Builds the Mod Project
.DESCRIPTION
    Builds the Mod Project using `divine.exe` (lslib). This includes building the
    localization files, lsf files and bumping the version number.
    Each execution of this script bumps the version (build) number - This behaviour can
    be altered by passing the $Version parameter. $Version accept the kind of
    version bump (i.e. `Major`, `Minor`, `Revision`, `Build` (Default)). You can also pass
    `None` ignore version updates.
.EXAMPLE
    . .\Build.ps1
    Builds the mod project and creates a `.pak` in the Build output directory
.EXAMPLE
    . .\Build.ps1 -WhatIf
    Performs a dry-run without actually making any changes. This will tell you what changes
    the script will make
.EXAMPLE
    . .\Build.ps1 -Version Revision
    Build the mod project and bumps the version (revision) number
.EXAMPLE
    . .\Build.ps1 -Confirm
    Asks for your confirmation as it builds the mod project.
.EXAMPLE
    . .\Build.ps1 -Archive
    Builds the mod project and create a `.zip` archive containing the `.pak` in the
    Build output directory 
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Path to the `meta.lsx` file. If not specified, will try to find the `meta.lsx` file in the workspace
    [ValidateScript({ (Test-Path -Path $_ -PathType Leaf) && ($_.EndsWith("meta.lsx")) })]
    [string] $Path = (Get-ChildItem -Path . -File -Recurse -Depth 5 -Filter meta.lsx | Select-Object -First 1 -ExpandProperty FullName),

    # Path to the Build Output directory
    [ValidateScript({ Test-Path -Path $_.DirectoryName -PathType Container })]
    [Alias("Output", "Out")]
    [string] $Destination = (Join-Path $PSScriptRoot ".." "Build"),

    # Switch to compress the .pak into an .zip archive
    [switch] $Archive,

    # The kind of version update
    [ValidateSet("Major", "Minor", "Revision", "Build", "None")]
    [string] $Version = "Build"
)

# Import Helpers
Get-ChildItem -Path .\Scripts\Helpers -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Update the path to point to the root folder
$Root = Get-ModRootFolder -Path $Path
$Path = $Root.FullName

# Check requirements
if (!(Get-Command -Name divine.exe -ErrorAction SilentlyContinue)) {
    throw "[FAIL] Could not find divine.exe (lslib). You may need to add divine.exe to your `$Env:PATH variable"
}

# Determine the ModName
$ModName = $Root.BaseName

# Build Localization Files
Get-ChildItem -Path "$ModName/Localization/" -Filter *.xml -File -Recurse | ForEach-Object {
    $dest = "$(Join-Path $_.DirectoryName $_.BaseName).loca"
    if ($PSCmdlet.ShouldProcess($_.FullName, "Create-Localization using divine.exe")) {
        divine --game bg3 --action convert-loca --source $_.FullName --destination $dest
    }
}

# Build lsx files
Get-ChildItem -Path "$ModName/Public" -Filter *.lsx -File -Recurse | ForEach-Object {
    $dest = "$(Join-Path $_.DirectoryName $_.BaseName).lsf"
    if ($PSCmdlet.ShouldProcess($_.FullName, "Create-Resource using divine.exe")) {
        divine --game bg3 --action convert-resource --source $_.FullName --destination $dest
    }
}

# Update Version Number
if ($Version -ne "None") {
    . $PSScriptRoot\Update-VersionNumber.ps1 -Kind $Version
}

# Build Package
$PakPath = Join-Path $Destination "$ModName.pak"
if ($PSCmdlet.ShouldProcess($Root.FullName, "Create-Package using divine.exe")) {
    divine --game bg3 --action create-package --source $Root.FullName --destination $PakPath
}

# Compress Archive, if the $Archive switch is set
if ($Archive) {
    $ArchivePath = Join-Path $Destination "$ModName.zip"
    if ($PSCmdlet.ShouldProcess($PakPath, "Archive the .pak")) {
        Compress-Archive -Path $PakPath -DestinationPath $ArchivePath
        Remove-Item -Path $PakPath
    }
}
