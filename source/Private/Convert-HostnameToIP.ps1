function Convert-HostnameToIP {
    <#
    .SYNOPSIS
    Convert a provided hostname to its resolved IP address
    .DESCRIPTION
    We need an IPv4 address in order to get a MAC for WOL. This function attempts to convert a hostname in to an IP address
    .PARAMETER ComputerName
    A computer name to target for WOL.  Will attempt to resolve the name to an IP address that will then be queried in ARP to determine a MAC.
    .EXAMPLE
    Convert-HostnameToIP 'ContosoComp'
    192.168.15.10
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String]$ComputerName
    )

    try {
        [System.Net.Dns]::GetHostEntry($ComputerName).AddressList.IPAddressToString | Where-Object {
            $_ -notmatch ':'
        }
    } catch {
        return $null
    }
}