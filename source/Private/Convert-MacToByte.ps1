function Convert-MacToByte {
    <#
    .SYNOPSIS
    Convert provided MAC address string to bytes
    .DESCRIPTION
    Accepts MAC addresses in multiple string formats and returns a byte array.  This function is necessary to provide compatibility across versions of PowerShell.
    .PARAMETER MacAddress
    Mac address to convert to a byte array.  Can be in any MAC format.
    .EXAMPLE
    Convert-MacToByte '6D-84-01-BC-D2-CD'
    #>
    [CmdletBinding()]
    param (
        [String]$MacAddress
    )

    try {
        $MacString = [System.Net.NetworkInformation.PhysicalAddress]::Parse(($MacAddress.ToUpper() -replace '[^0-9A-F]',''))
        $MacString.GetAddressBytes()
    } catch {
        throw "An invalid physical address was specified: $MacAddress"
    }
}