function Convert-HostnameToIP {
    <#
    .SYNOPSIS
    Convert a provided hostname to its resolved IP address
    .DESCRIPTION
    We need an IPv4 address in order to get a MAC for WOL. This function attempts to convert a hostname in to an IP address
    #>
    [CmdletBinding()]
    param (
        [String]$ComputerName
    )

    try {
        [System.Net.Dns]::GetHostEntry($ComputerName).AddressList.IPAddressToString | Where-Object {
            $_ -notmatch ':'
        }
    } catch {
        return "NotFound"
    }
}