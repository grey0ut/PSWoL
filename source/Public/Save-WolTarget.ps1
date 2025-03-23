function Save-WolTarget {
    <#
    .SYNOPSIS
    Save a MAC address along with a name for use with Send-WakeOnLan.
    .DESCRIPTION
    Save a MAC address along with a name for use with Send-WakeOnLan.  The name is purely decorative and does not have to be resolvable.  It does have to be unique amongst saved names.
    .PARAMETER Name
    A name to refer to the saved target by
    .PARAMETER MacAddress
    MAC address of the saved target. Acceptable formats are:
    00:1a:1e:12:af:38
    00-1a-1e-12-af-38
    001A.1E12.AF38
    001A1E12AF38
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Name,
        [Parameter(Mandatory)]
        [ValidateScript({
            if ($_ -match '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})|([0-9a-fA-F]{4}.[0-9a-fA-F]{4}.[0-9a-fA-F]{4})|([0-9a-fA-F]{12})$') {
                return $true
            } else {
                throw "Provided MAC not in an acceptable format."
            }
        })]
        [String]$MacAddress
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
        $SavedTargets = @{}
    }

    try {
        $SavedTargets.Add($Name, $MacAddress)
    } catch [System.Management.Automation.MethodInvocationException] {
        throw "$Name already exists in saved targets. If you want want to use this name, remove the current entry with Remove-WolTarget -Name $Name"
    }

    try {
        if (Test-Path $SettingsFile) {
            Write-Verbose "Saving targets to $($SettingsFile)"
            $SavedTargets | ConvertTo-Json | Out-File -FilePath $SettingsFile -Force
            } else {
                Write-Verbose "Saving targets to $($SettingsFile)"
                New-Item -Path $SettingsFile -Force | Out-Null
                $SavedTargets | ConvertTo-Json | Out-File -FilePath $SettingsFile
            }
    } catch {
        throw $_
    }

}