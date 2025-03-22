function Convert-MacToBytes {
    <#
    .SYNOPSIS
    Convert provided MAC address string to bytes
    .DESCRIPTION
    Accepts MAC addresses in multiple string formats and returns a byte array.  This function is necessary to provide compatibility across versions of PowerShell.
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