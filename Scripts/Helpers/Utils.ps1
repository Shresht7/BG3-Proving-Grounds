# Import Version Helper Functions
. .\Scripts\Helpers\Version.ps1

<#
.SYNOPSIS
    Returns the path of the mod's root folder
.DESCRIPTION
    Returns the path of the mod's root folder. This derived on the fact
    that the `meta.lsx` file has to be at a specific location in the mods folder structure.
    i.e. `[RootFolder]\Mods\[ModFolder]\meta.lsx`.
    The path to the root can be determined by simply walking up 3 directories from the `meta.lsx` file.
#>
function Get-ModRootFolder(
    # Path to the `meta.lsx` file. If not specified, will try to find the `meta.lsx` file in the workspace
    [ValidateScript({ (Test-Path -Path $_ -PathType Leaf) && ($_.EndsWith("meta.lsx")) })]
    [string] $Path = (Get-ChildItem -Path . -File -Recurse -Depth 5 -Filter meta.lsx | Select-Object -First 1 -ExpandProperty FullName)
) {
    $Splat = @(
        $Path, # Path to the `meta.lsx` file
        "..", # [ModFolder]
        "..", # Mods
        ".."  # [RootFolder]
    )
    return Resolve-Path (Join-Path @Splat) | Get-Item
}

<#
.SYNOPSIS
    Parses the `meta.lsx` file and returns an XML object
#>
function Get-MetaLSXData(
    # Path to the `meta.lsx` file. If not specified, will try to find the `meta.lsx` file in the workspace
    [ValidateScript({ (Test-Path -Path $_ -PathType Leaf) && ($_.EndsWith("meta.lsx")) })]
    [string] $Path = (Get-ChildItem -Path . -File -Recurse -Depth 5 -Filter meta.lsx | Select-Object -First 1 -ExpandProperty FullName)
) {
    # Read the `meta.lsx` file
    $MetaXML = [xml](Get-Content -Path $Path)

    # Return the XMLData object
    return [PSCustomObject]@{
        Author      = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Author']")
        Name        = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Name']")
        Description = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Description']")
        Folder      = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Folder']")
        UUID        = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='UUID']")
        Version64   = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Version64']")
        Tags        = $MetaXML.SelectSingleNode("//node[@id='ModuleInfo']/attribute[@id='Tags']")
    }
}
