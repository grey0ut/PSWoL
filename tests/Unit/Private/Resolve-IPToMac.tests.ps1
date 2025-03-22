
BeforeAll {
    Import-Module $ModuleName
}

Describe 'Resolve-IPToMac' {
    InModuleScope $ModuleName {
        It 'Should resolve Gateway address to MAC' {
            $Interfaces = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | Where-Object { $_.NetworkInterfaceType -ne [System.Net.NetworkInformation.NetworkInterfaceType]::Loopback -and $_.OperationalStatus -eq [System.Net.NetworkInformation.OperationalStatus]::Up } 
            $Interface = $Interfaces | Select-Object -First 1
            $GWAddress = $Interface.GetIPProperties().GatewayAddresses.Address.IPAddressToString
            $Result = Resolve-IPToMac -IPAddress $GWAddress
            Write-Host "GW MAC: $($Result.ToString())"
            $Result.ToString().Length -eq 12 | Should -BeTrue
        }
        It 'Should fail to process a non-valid IP address' {
            try {
                $Result = Resolve-IPToMac -IPAddress '00-00-0A-BB-28-FC'
                $Success = $false
            } catch {
                $Sucess = $true
            }
            $Sucess | Should -BeTrue
        }
    }
}