function Get-WolTarget {
    <#
    
    #>
    [CmdletBinding()]
    param (

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
        Write-Warning "No saved target named $Name"
        return $null
    }
}