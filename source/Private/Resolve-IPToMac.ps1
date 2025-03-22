function Resolve-IPToMac {
    <#
    .SYNOPSIS
    Resolve an IP address to a MAC address
    .DESCRIPTION
    Attempts to find the corresponding MAC address for a given IP address
    #>
    [CmdletBinding()]
    param (
        [String]$IPAddress
    )

    # check to see if we're on Windows or not
    if ($IsWindows -or $ENV:OS) {
        $Windows = $true
    } else {
        $Windows = $false
    }

    if ($Windows) {
        $Result = Get-NetNeighbor -IPAddress $IPAddress -AddressFamily IPv4 | Where-Object {
            $_.LinkLayerAddress -ne ''
        }
        $Result.LinkLayerAddress
    } else {
        $Arp = Get-Command arp | Select-Object -ExpandProperty Source
        $Regex =  '{0}.+{1}' -f $([Regex]::Escape($IPAddress)), '(?<MAC>([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2}))'
        $ArpResult = & $Arp -a
        foreach ($Line in $ArpResult) {
            if ($Line -match $Regex) {
                $Matches.MAC
                continue
            }
        }
    }
}