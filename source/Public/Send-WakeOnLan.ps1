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
        [String[]]$MacAddress,
        [Parameter(ValueFromPipeline,ParameterSetName="ComputerName")]
        [String[]]$ComputerName
    )

    begin {
        $UdpClient = [System.Net.Sockets.UdpClient]::new()
        [Byte[]]$BasePacket = (,0xFF * 6)
        $Targets = [System.Collections.ArrayList]::new()
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'IP' {
                foreach ($TargetIP in $IPAddress) {
                    $ResolvedMac = Resolve-IPToMac -IPAddress $TargetIP
                    if ($ResolvedMac) {
                        $MacBytes = Convert-MacToBytes -MacAddress $ResolvedMac
                        [Void]$Targets.Add(
                            [PSCustomObject]@{
                                Identifier = $TargetIP
                                Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                            }
                        )
                    } else {
                        Write-Warning "Unable to determine MAC for $TargetIP"
                    }
                }
            }
            'Mac' {
                foreach ($TargetMac in $MacAddress) {
                    $MacBytes = Convert-MacToBytes -MacAddress $TargetMac
                    [Void]$Targets.Add(
                        [PSCustomObject]@{
                            Identifier = $TargetMac
                            Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                        }
                    )
                }
            }
            'ComputerName' {
                foreach ($Computer in $ComputerName) {
                    $ResolvedIP = Convert-HostnameToIP -ComputerName $Computer
                    if ($ResolvedIP) {
                        $Mac = Resolve-IPToMac -IPAddress $ResolvedIP
                        if ($Mac) {
                            $MacBytes = Convert-MacToBytes -MacAddress $Mac
                            [Void]$Targets.Add(
                                [PSCustomObject]@{
                                    Identifier = $Computer
                                    Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                                }
                            )
                        } else {
                            Write-Warning "Unable to determine MAC for $ResolvedIP"
                        }
                    } else {
                        Write-Warning "Unable to resolve IP for $Computer"
                    }
                }
            }
        }

    }

    end {
        # sent packet to targets
        foreach ($Target in $Targets) {
            try {
                $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),9)
                [Void]$UdpClient.Send($($Target.Packet), $($Target.Packet.Length))
                Write-Verbose "Wake-on-LAN packet sent to $($Target.Identifier)"
            } catch {
                Write-Warning "Error sending WOL packet"
            }
        }
        $UdpClient.Close()
        $UdpClient.Dispose()
    }
}