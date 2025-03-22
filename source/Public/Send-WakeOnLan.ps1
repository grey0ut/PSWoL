function Send-WakeOnLan {
    <#
    .SYNOPSIS
    Send a Wake-On-LAN packet to a target address.
    .DESCRIPTION
    Sends a Wake-On-LAN packet to a target address. Target address can be a MAC address, IP address or potentially a computer name    
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,Mandatory)]
        [String[]]$TargetAddress
    )

    begin {
        $UdpClient = [System.Net.Sockets.UdpClient]::new()
        [Byte[]]$BasePacket = (,0xFF * 6)
        $WolTargets = [System.Collections.ArrayList]::new()
    }

    process {
        foreach ($Target in $TargetAddress) {
            switch (Resolve-TargetType -Target $Target) {
                'IPAddress' {
                    $ResolvedMac = Resolve-IPToMac -IPAddress $Target
                    if ($ResolvedMac) {
                        $MacBytes = Convert-MacToBytes -MacAddress $ResolvedMac
                        [Void]$WolTargets.Add(
                            [PSCustomObject]@{
                                Identifier = $Target
                                Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                            }
                        )
                    } else {
                        Write-Warning "Unable to determine MAC for $Target"
                    }
                }
                'MacAddress' {
                    $MacBytes = Convert-MacToBytes -MacAddress $Target
                    if ($MacBytes) {
                        [Void]$WolTargets.Add(
                            [PSCustomObject]@{
                                Identifier = $Target
                                Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                            }
                        )
                    } else {
                        Write-Warning "Unable to convert MAC to bytes: $Target"
                    }
                }
                'ComputerName' {
                    $ResolvedIP = Convert-HostnameToIP -ComputerName $Target
                    if ($ResolvedIP) {
                        $Mac = Resolve-IPToMac -IPAddress $ResolvedIP
                        if ($Mac) {
                            $MacBytes = Convert-MacToBytes -MacAddress $Mac
                            [Void]$WolTargets.Add(
                                [PSCustomObject]@{
                                    Identifier = $Target
                                    Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                                }
                            )
                        } else {
                            Write-Warning "Unable to determine MAC for $ResolvedIP"
                        }
                    } else {
                        Write-Warning "Unable to resolve IP for $Target"
                    }
                }
            }
        }
    }

    end {
        # sent packet to targets
        foreach ($WolTarget in $WolTargets) {
            try {
                $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),9)
                [Void]$UdpClient.Send($($WolTarget.Packet), $($WolTarget.Packet.Length))
                Write-Verbose "Wake-on-LAN packet sent to $($WolTarget.Identifier)"
            } catch {
                Write-Warning "Error sending WOL packet"
            }
        }
        $UdpClient.Close()
        $UdpClient.Dispose()
    }
}