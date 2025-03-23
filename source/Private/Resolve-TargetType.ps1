function Resolve-TargetType {
    <#
    .SYNOPSIS
    Determine if a provided string is an IP address, MAC address, or computername (possibly)
    .DESCRIPTION
    Takes an input string and returns a string value representing whether the input was an IP address, MAC address, or computername
    .PARAMETER Target
    Takes the provided target for a WOL packet and determines if it's a MAC address, IP address or computer name.
    .EXAMPLE
    Resolve-TargetType 192.168.15.10
    IPAddress
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String]$Target
    )

    $MacReg = '^([[:xdigit:]]{2}[:.-]?){5}[[:xdigit:]]{2}$'
    if ($Target -match $MacReg) {
        return "MacAddress"
    } elseif ([System.Net.IPAddress]::TryParse($Target,[ref]0)) {
        return "IPAddress"
    } else {
        # possibly a computername but it's impossible to tell
        return "ComputerName"
    }
}