<#
.SYNOPSIS
    Updates the version number in the `meta.lsx` file
.DESCRIPTION
    Bumps and updates the version number in the `meta.lsx` files
    as specified. (Defaults to `Build`)
.EXAMPLE
    . .\Scripts\Update-VersionNumber.ps1
    Bumps the version number build by 1. (1.0.0.0 --> 1.0.0.1)
.EXAMPLE
    . .\Scripts\Update-VersionNumber.ps1 -Kind Minor
    Bumps the minor version number by 1. (1.0.2.14 --> 1.1.0.0)
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Path to the `meta.lsx` file. If not specified, will try to find the `meta.lsx` file in the workspace
    [ValidateScript({ (Test-Path -Path $_ -PathType Leaf) && ($_.EndsWith("meta.lsx")) })]
    [string] $Path = (Get-ChildItem -Path . -File -Recurse -Depth 5 -Filter meta.lsx | Select-Object -First 1 -ExpandProperty FullName),

    # The kind of version update. Should be one of `Major`, `Minor`, `Revision`, `Build`
    [ValidateSet("Major", "Minor", "Revision", "Build")]
    [string] $Kind = "Build"
)

# Import Helpers
. .\Scripts\Helpers\Version.ps1

# Get `meta.lsx` content and extract the current version number
$MetaXML = [xml](Get-Content -Path $Path)
$Version64Attribute = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Version64']")
$OldVersion64 = $Version64Attribute.Value
$OldVersion = Convert-VersionNumber -Version64 $OldVersion64

Write-Verbose "Read `meta.lsx` file: $Path"
Write-Verbose "Current Version: $OldVersion64 ($OldVersion)"

# Update the version number
$NewVersion64 = Update-VersionNumber -Version64 $OldVersion64 -Kind $Kind -As "Version64"
$NewVersion = Convert-VersionNumber -Version64 $NewVersion64

# Update the Version64 attribute in the XML data
$Version64Attribute.SetAttribute("value", $NewVersion64)
Write-Verbose "New Version: $NewVersion64 ($NewVersion)"

# Write the update contents back to the file
$Msg = "Update version number from $($OldVersion64) ($($OldVersion)) to $($NewVersion64) ($($NewVersion))"
if ($PSCmdlet.ShouldProcess($Path, $Msg)) {
    $StringWriter = New-Object System.IO.StringWriter
    $Writer = New-Object System.Xml.XmlTextwriter($StringWriter)
    $Writer.Formatting = [System.XML.Formatting]::Indented
    $MetaXML.WriteContentTo($Writer)
    $StringWriter.ToString() | Out-File -FilePath $Path -Encoding utf8
    Write-Verbose $Msg
    Write-Verbose "Updated `meta.lsx` file: $Path"
}
