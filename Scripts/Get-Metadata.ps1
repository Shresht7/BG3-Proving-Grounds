<#
.SYNOPSIS
    Returns the metadata from the `meta.lsx` file
.DESCRIPTION
    Parses the metadata from the `meta.lsx` file and returns it as an object.
    The $Select parameter can be used to only select the given attribute.
.EXAMPLE
    . .\Scripts\Get-Metadata.ps1
    Returns the entire metadata object
.EXAMPLE
    . .\Scripts\Get-Metadata.ps1 -Select UUID
    Returns the mod's UUID
#>
param(
    # Path to the `meta.lsx` file
    [ValidateScript({ (Test-Path -Path $_ -PathType Leaf) && ($_.EndsWith("meta.lsx")) })]
    [string] $Path = (Get-ChildItem -Path . -File -Recurse -Filter meta.lsx | Select-Object -First 1 -ExpandProperty FullName),

    # Select a particular attribute
    [ValidateSet('Author', 'Name', 'Description', 'UUID', 'Folder', 'Version', 'Version64', 'Tags')]
    [string] $Select
)

# Import Helper Functions
Get-ChildItem -Path .\Scripts\Helpers -File -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$MetaLSX = Get-MetaLSXData -Path $Path

# Calculate the string version
$Version = Convert-VersionNumber -Version64 $MetaLSX.Version64.Value

# Create the metadata object
$Metadata = [PSCustomObject]@{
    Author      = $MetaLSX.Author.Value
    Name        = $MetaLSX.Name.Value
    Description = $MetaLSX.Description.Value
    Folder      = $MetaLSX.Folder.Value
    UUID        = $MetaLSX.UUID.Value
    Version     = $Version
    Version64   = [long] $MetaLSX.Version64.Value
    Tags        = $MetaLSX.Tags.Value
}

# Return the selected property if $Select is not null
if ($Select) {
    return $Metadata | Select-Object -ExpandProperty $Select
}

# Return the metadata
return $Metadata
