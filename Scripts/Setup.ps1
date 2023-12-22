<#
.SYNOPSIS
    Setup the project workspace
.DESCRIPTION
    Performs the initial setup for the project workspace by renaming files and folders,
    removing unneeded files, and substituting placeholder values.
.EXAMPLE
    . .\Scripts\Setup.ps1
    Simply run the script. It will ask you for the ModName and generate the ModUUID automatically
.EXAMPLE
    . .\Scripts\Setup.ps1 -Name MyMod
    Run the script and specify the mod's name as `MyMod`. UUID will be auto-generated
.EXAMPLE
    . .\Scripts\Setup.ps1 -Name MyMod -UUID ((New-Guid).ToString())
    Run the script specifying both the ModName and the ModUUID
.EXAMPLE
    . .\Scripts\Setup.ps1 -Name MyMod -Author Shresht7 -Tags "spell;balance;class;combat"
    Run the script specifying the ModName, AuthorName and the ModTags
#>
param(
    # Name of the Mod. Please use an unique identifier like PREFIX_ModName (e.g. S7_Config)
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,

    # UUID: A universally unique identifier for the mod
    [ValidatePattern('^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')]
    [string] $UUID = ((New-Guid).ToString()),

    # The description of the mod
    [string] $Description,

    # A string of tags/keywords describing the mod (delimited by a semi-colon)
    [string] $Tags,

    # Name of the mod author
    [string] $Author
)

# Placeholder values and their replacements
$Placeholders = @(
    @("_____MODNAME_____", $Name),
    @("_____MODUUID_____", $UUID),
    @("_____DESCRIPTION_____", $Description),
    @("_____TAGS_____", $Tags),
    @("_____AUTHOR_____", $Author)
)

# Iterate over every file and directory in this workspace
Get-ChildItem -Recurse | ForEach-Object {
    
    # Rename all placeholder files and directories. That is items with _____MODNAME_____ and _____MODUUID_____ placeholders.
    if ($_.BaseName.EndsWith("_____MODNAME_____") -or $_.BaseName.EndsWith("_____MODUUID_____")) {
        $NewName = $_.FullName.Replace("_____MODNAME_____", $Name).Replace("_____MODUUID_____", $UUID)
        Write-Verbose "Renaming $($_.FullName.Split($PWD)[-1]) to $($NewName.Split($PWD)[-1])"
        Rename-Item -Path $_.FullName -NewName $NewName.Split("\")[-1] -Force
    }

    # Replace placeholders in the file-contents
    if (Test-Path -Path $_.FullName -PathType Leaf) {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        foreach ($X in $Placeholders) {
            if ($X[1]) {
                # If the placeholder actually has a value to substitute ...
                $content = $content.Replace($X[0], $X[1])
            }
        }
        $null = [System.IO.File]::WriteAllText($_.FullName, $content)
    }

    # Remove all .gitkeep files
    Write-Verbose "Removing .gitkeep files"
    if ($_.FullName.EndsWith(".gitkeep")) {
        Remove-Item -Path $_.FullName -Force
    }

}

# Success Message
Write-Host "✅ Successfully setup the mod workspace!"
