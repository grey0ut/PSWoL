function Send-WakeOnLan {
    <#
    .SYNOPSIS
    Send a Wake-On-LAN packet to a target address.
    .DESCRIPTION
    Sends a Wake-On-LAN packet to a target address. Target address can be a MAC address, IP address or potentially a computer name
    .PARAMETER TargetAddress
    Target address to send Wake-On-LAN packet to. Accepts IP address, MAC address or Computer Name.
    IP must be an IPv4 address.
    MAC addresses can be '1234.abde.4321', '12:34:AB:DE:43:21', '12-34-AB-DE-32-21' or '1234ABDE4321' format.
    Computername needs to be able to resolve to a local computer name. If resolution fails, the packet will not send.
    .PARAMETER SavedTarget
    If there are currently saved target addresses via Save-WolTarget you can specify their name(s) with -SavedTarget to send a WoL packet to them.
    .EXAMPLE
    PS> Send-WakeOnLan -TargetAddress '192.168.15.10'

    # this will attempt to do an ARP lookup for that IP address and send a WOL packet to it
    .EXAMPLE
    PS> 'E2-5D-0E-B5-E2-E8', 'DD-20-C9-FF-EC-79', '6D-84-01-BC-D2-CD' | Send-WakeOnLan

    # this will send a WOL packet to each of the 3 MAC addresses.
    .EXAMPLE
    PS> Send-WakeOnLan -SavedTarget "TheGibson"

    # this will check the saved targets for the name "TheGibson" and send a WoL packet to the MAC address associated with that name.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipeline,Mandatory,ParameterSetName="TargetAddress")]
        [String[]]$TargetAddress,
        [Parameter(ValueFromPipeline,Mandatory,ParameterSetName="SavedTarget")]
        [String[]]$SavedTarget
    )

    begin {
        $UdpClient = [System.Net.Sockets.UdpClient]::new()
        [Byte[]]$BasePacket = (,0xFF * 6)
        $WolTargets = [System.Collections.ArrayList]::new()
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Targetaddress' {
                foreach ($Target in $TargetAddress) {
                    switch (Resolve-TargetType -Target $Target) {
                        'IPAddress' {
                            $ResolvedMac = Resolve-IPToMac -IPAddress $Target
                            if ($ResolvedMac) {
                                $MacBytes = Convert-MacToByte -MacAddress $ResolvedMac
                                [Void]$WolTargets.Add(
                                    [PSCustomObject]@{
                                        Identifier = $Target
                                        MacAddress = $([System.BitConverter]::ToString($MacBytes))
                                        Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                                    }
                                )
                            } else {
                                Write-Warning "Unable to determine MAC for $Target"
                            }
                        }
                        'MacAddress' {
                            $MacBytes = Convert-MacToByte -MacAddress $Target
                            if ($MacBytes) {
                                [Void]$WolTargets.Add(
                                    [PSCustomObject]@{
                                        Identifier = $Target
                                        MacAddress = $([System.BitConverter]::ToString($MacBytes))
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
                                    $MacBytes = Convert-MacToByte -MacAddress $Mac
                                    [Void]$WolTargets.Add(
                                        [PSCustomObject]@{
                                            Identifier = $Target
                                            MacAddress = $([System.BitConverter]::ToString($MacBytes))
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
            'SavedTarget' {
                $SavedTargets = foreach ($Target in $SavedTarget) {
                    Get-WolTarget -Name $Target
                }

                foreach ($TargetObj in $SavedTargets) {
                    $MacBytes = Convert-MacToByte -MacAddress $($TargetObj.MAC)
                    [Void]$WolTargets.Add(
                        [PSCustomObject]@{
                            Identifier = $TargetObj.Name
                            MacAddress = $([System.BitConverter]::ToString($MacBytes))
                            Packet = [Byte[]]$($BasePacket; $MacBytes * 16)
                        }
                    )
                }
            }
        }
    }

    end {
        # sent packet to targets
        foreach ($WolTarget in $WolTargets) {
            if ($PSCmdlet.ShouldProcess($($WolTarget.Identifier),"Send WOL Packet")) {
                try {
                    $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),9)
                    [Void]$UdpClient.Send($($WolTarget.Packet), $($WolTarget.Packet.Length))
                    Write-Verbose "Wake-on-LAN packet sent to target:$($WolTarget.Identifier)     MAC: $($WolTarget.MacAddress)"
                } catch {
                    Write-Warning "Error sending WOL packet"
                }
            }
        }
        $UdpClient.Close()
        $UdpClient.Dispose()
    }
}