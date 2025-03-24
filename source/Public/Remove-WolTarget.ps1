function Remove-WolTarget {
    <#
    .SYNOPSIS
    Remove a saved target from the local settings file
    .DESCRIPTION
    Removes a saved target by name from the saved settings file.  Optionally can also delete the entire saved settings file.
    .PARAMETER Name
    The name used by the saved target. Needs to be an exact match.  If you're not sure, run Get-WolTarget first to list all currently saved targets.
    .PARAMETER DeleteAll
    Switch parameter to delete the saved targets file entirely
    .EXAMPLE
    PS> Remove-WolTarget -Name "Gibson2"

    # will remove the saved entry with the name "Gibson2"
    .EXAMPLE
    PS> Remove-WolTarget -DeleteAll

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove-Item" on target "C:\Users\Admin\AppData\Roaming\PSWoL\Settings.json".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

    # after confirming this will delete the saved settings file stored locally
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'DeleteAll', Justification = 'Switch parameter where variable is not directly called')]
    param (
        [Parameter(Mandatory,Position=0,ParameterSetName="Name")]
        [String]$Name,
        [Parameter(ParameterSetName="Delete")]
        [Switch]$DeleteAll
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
        switch ($PSCmdlet.ParameterSetName) {
            'Name' {
                try {
                    if ($SavedTargets.$Name) {
                        Write-Verbose "Removing saved target  Name: $Name     MAC: $($SavedTargets.$Name)"
                        $SavedTargets.Remove($Name)
                        if ($SavedTargets.Count -eq 0) {
                            Write-Warning "Last saved entry removed, deleting saved file"
                            Remove-WolTarget -DeleteAll -Confirm:$false
                        } else {
                            Write-Verbose "Saving changes to $($SettingsFile)"
                            $SavedTargets | ConvertTo-Json | Out-File -FilePath $SettingsFile -Force
                        }
                    } else {
                        Write-Warning "No saved target found by name: $Name"
                    }
                } catch {
                    throw $_
                }
            }
            'Delete' {
                if ($PSCmdlet.ShouldProcess($SettingsFile, 'Remove-Item')) {
                    try {
                        Remove-Item -Path $SettingsFile -Force -ErrorAction Stop
                    } catch {
                        throw $_
                    }
                }
            }
        }

    } else {
        Write-Warning "No saved targets"
    }
}