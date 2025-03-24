function Get-WolTarget {
    <#
    .SYNOPSIS
    Retrieved a saved target from local file
    .DESCRIPTION
    Can retrieve a saved target's MAC by memorable name or if called with no -Name parameter will return a table of all saved targets.
    .PARAMETER Name
    The name to look up in the saved targets file. Must be an exact match
    .EXAMPLE
    PS> Get-WolTarget
    Name                           Value
    ----                           -----
    gibson2                        16:12:EB:E0:32:28
    Gibson1                        16:12:EB:E0:32:28

    # returns all of the saved targets if present.
    .EXAMPLE
    PS> Get-WolTarget -Name gibson1
    Name    MAC
    ----    ---
    gibson1 16:12:EB:E0:32:28

    # returns a PSCustomobject with the name and MAC of the saved target
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [String]$Name
    )

    try {
        $SettingsFile = Get-SettingsPath
    } catch {
        throw "Could not retrieve settings file path"
    }

    if (Test-Path $SettingsFile) {
        # load existing saved targets
        $JsonData = Get-Content -Path $SettingsFile | ConvertFrom-Json
        $SavedTargets = @{}
        $JsonData.PSObject.Properties | Foreach-Object {
            $SavedTargets.Add($_.Name, $_.Value)
        }
    } else {
        Write-Warning "No saved targets"
        return $null
    }

    if ($Name) {
        if ($SavedTargets.$Name) {
            [PSCustomObject]@{
                Name = $Name
                MAC = $SavedTargets.$Name
            }
        } else {
            Write-Warning "No saved target found by name: $Name"
        }
    } else {
        $SavedTargets
    }
}