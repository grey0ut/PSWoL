function Get-WolTarget {
    <#
    .SYNOPSIS
    Retrieved a saved target from local file
    .DESCRIPTION
    Can retrieve a saved target's MAC by memorable name or if called with no -Name parameter will return a table of all saved targets.
    .PARAMETER Name
    The name to look up in the saved targets file. Must be an exact match 
    #>
    [CmdletBinding()]
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