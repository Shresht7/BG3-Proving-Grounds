<#
.SYNOPSIS
    Parses the UInt64 version number (e.g. 36028797018963968) as a powershell object
.DESCRIPTION
    Parses the UInt64 version number (e.g. 36028797018963968) as a powershell object.
    This object contains the `Major`, `Minor`, `Revision` and `Build` fields
    to represent the Version number.
#>
function parseVersion64([long] $Version64) {
    return [PSCustomObject]@{
        Major    = $Version64 -shr 55
        Minor    = ($Version64 -shr 47) -band 0xFF
        Revision = ($Version64 -shr 31) -band 0xFFFF
        Build    = $Version64 -band 0x7FFFFFF
    }
}

<#
.SYNOPSIS
    Parses the string version number (e.g. 1.0.3.7) as a powershell object
.DESCRIPTION
    Parses the string version number (e.g. 1.0.3.7) as a powershell object.
    This object contains the `Major`, `Minor`, `Revision` and `Build` fields
    to represent the Version number.
#>
function parseVersion(
    [ValidatePattern("^\d\.\d\.\d\.\d$")]
    [string] $Version
) {
    $Major, $Minor, $Revision, $Build = $Version.Split(".")
    return [PSCustomObject]@{
        Major    = [int] $Major
        Minor    = [int] $Minor
        Revision = [int] $Revision
        Build    = [int] $Build
    }   
}

<#
.SYNOPSIS
    Converts the Version object to a string version number (e.g. 1.0.3.6)
#>
function toVersion([object] $V) {
    return "$($V.Major).$($V.Minor).$($V.Revision).$($V.Build)"
}

<#
.SYNOPSIS
    Converts the Version object to a UInt64 version number (e.g. 36028797018963968)
#>
function toVersion64([object] $V) {
    # Perform conversion
    $Major = ([long] $V.Major -shl 55)
    $Minor = ([long] $V.Minor -shl 47)
    $Revision = ([long] $V.Revision -shl 31)
    $Build = [long] $V.Build
    # Calculate the Version64
    return $Major + $Minor + $Revision + $Build
}

<#
.SYNOPSIS
    Converts the version number from one form to another
.DESCRIPTION
    Accepts the version number in either the string form (e.g. 1.0.2.4)
    or the long-int form (e.g. 36028797018963968) and converts it to the other
    form.
#>
function Convert-VersionNumber(
    # The string representation of the version number
    [Parameter(ParameterSetName = "Version")]
    [ValidatePattern("^\d\.\d\.\d\.\d$")]
    [string] $Version = "1.0.0.0",

    # The long int version number
    [Parameter(ParameterSetName = "Version64")]
    [long] $Version64
) {
    # If the input is a Version64
    if ($PSCmdlet.ParameterSetName -eq "Version64") {
        $V = parseVersion64($Version64)
        return toVersion($V)
    }
    # Else if the input is a string version
    else {
        $V = parseVersion($Version)
        return toVersion64($V)
    }
}

<#
.SYNOPSIS
    Updates the version number by the specified kind.
.DESCRIPTION
    Bumps and updates the given version number by the specified kind.
    The version can be provided as a string `1.0.0.0` or as a long int `36028797018963968`.
    The kind must be one of type: `Major`, `Minor`, `Revision`, `Build`.
    The updated version can be returned as an object, a string (e.g. 1.0.2.4) or a
    long int (e.g. 36028797018963968)
#>
function Update-VersionNumber(
    # The string representation of the version number
    [Parameter(ParameterSetName = "Version")]
    [ValidatePattern("^\d\.\d\.\d\.\d$")]
    [string] $Version = "1.0.0.0",

    # The long int version number
    [Parameter(ParameterSetName = "Version64")]
    [long] $Version64,

    # The kind of version bump
    [ValidateSet("Major", "Minor", "Revision", "Build")]
    [string] $Kind,

    # Return the version as
    [ValidateSet("Version", "Version64")]
    [string] $As
) {
    # Parse the version
    $V = if ($PSCmdlet.ParameterSetName -eq "Version64") {
        parseVersion64($Version64)
    }
    else {
        parseVersion($Version)
    }

    # Perform the version bump
    switch ($Kind) {
        "Major" {
            $V.Major++
            $V.Minor = 0
            $V.Revision = 0
            $V.Build = 0
        }

        "Minor" {
            $V.Minor++
            $V.Revision = 0
            $V.Build = 0
        }

        "Revision" {
            $V.Revision++
            $V.Build = 0
        }

        "Build" {
            $V.Build++
        }
    }

    # Return the updated version number
    if (!$As) {
        return $V
    }
    # Return the update version number as specified in $As
    else {
        switch ($As) {
            "Version" { return toVersion($V) }
            "Version64" { return toVersion64($V) }
        }
    }
}
