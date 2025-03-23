function Resolve-IPToMac {
    <#
    .SYNOPSIS
    Resolve an IP address to a MAC address
    .DESCRIPTION
    Attempts to find the corresponding MAC address for a given IP address
    .PARAMETER IPAddress
    The IP address to look up in ARP and find a corresponding MAC address to send a WOL packet to.
    Must be an IPv4 address.
    .EXAMPLE
    Resolve-IPToMac '192.168.15.10'
    6D-84-01-BC-D2-CD
    #>
    [CmdletBinding()]
    [OutputType([System.Net.NetworkInformation.PhysicalAddress])]
    param (
        [ValidateScript({
            if ([IPAddress]::TryParse($_, [ref]0)) {
                return $true
            } else {
                throw "Error: Not a valid IP address."
            }
        })]
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
        [System.Net.NetworkInformation.PhysicalAddress]::Parse(($Result.LinkLayerAddress.ToUpper() -replace '[^0-9A-F]',''))
    } else {
        $Arp = Get-Command -Name "arp" | Select-Object -ExpandProperty Source
        $Regex =  '{0}.+{1}' -f $([Regex]::Escape($IPAddress)), '(?<MAC>([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2}))'
        $ArpResult = & $Arp -a
        foreach ($Line in $ArpResult) {
            if ($Line -match $Regex) {
                [System.Net.NetworkInformation.PhysicalAddress]::Parse(($Matches.MAC.ToUpper() -replace '[^0-9A-F]',''))
                continue
            }
        }
    }
}
