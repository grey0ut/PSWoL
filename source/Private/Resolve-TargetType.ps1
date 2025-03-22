function Resolve-TargetType {
    <#
    .SYNOPSIS
    Determine if a provided string is an IP address, MAC address, or computername (possibly)
    .DESCRIPTION
    Takes an input string and returns a string value representing whether the input was an IP address, MAC address, or computername
    #>
    [CmdletBinding()]
    param (
        [String]$Target
    )

    $MacReg = '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})|([0-9a-fA-F]{4}\.[0-9a-fA-F]{4}\.[0-9a-fA-F]{4})$'
    if ($Target -match $MacReg) {
        return "MacAddress"
    } elseif ([System.Net.IPAddress]::TryParse($Target,[ref]0)) {
        return "IPAddress"
    } else {
        # possibly a computername but it's impossible to tell
        return "ComputerName"
    }
}