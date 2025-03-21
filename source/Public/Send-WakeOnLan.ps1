function Send-WakeOnLan {
    <#
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ParameterSetName="IP")]
        [ValidateScript({
            if ([IPAddress]::TryParse($_, [ref]0)) {
                return $true
            } else {
                throw "Error: Not a valid IP address."
            }
        })]
        [String[]]$IPAddress,
        [Parameter(ValueFromPipeline,ParameterSetName="Mac")]
        [System.Net.NetworkInformation.PhysicalAddress[]]$MacAddress
    )

    begin {
        $UdpClient = [System.Net.Sockets.UdpClient]::new()
    }

}