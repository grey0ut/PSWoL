function Get-SettingsPath {
    <#
    .SYNOPSIS
    Determine the path where saved targets are stored.
    .DESCRIPTION
    Depending on the OS, return an appropriate path relative to the user to store a json file containing saved targets.
    
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        # no params
    )

    if ($IsWindows -or $ENV:OS) {
        $Windows = $true
    } else {
        $Windows = $false
    }
    if ($Windows) {
        $SettingsPath = Join-Path -Path $Env:APPDATA -ChildPath "PSWoL\Settings.json"
    } else {
        $SettingsPath = Join-Path -Path ([Environment]::GetEnvironmentVariable("HOME")) -ChildPath ".local/share/powershell/Modules/PSWoL/Settings.json"
    }
    return $SettingsPath
}