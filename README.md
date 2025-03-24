<div align='center'>
<img src='Assets/PSWoL.svg' />
</div>  

## PSWoL

Module for sending Wake-on-LAN (Magic) packets to target(s).  A Wake-on-LAN packet is a special packet sent via UDP to the LAN broadcast address on an arbitrary port (9). 
You can read more about Wake-on-LAN on [Wikipedia](http://en.wikipedia.org/wiki/Wake-on-LAN).  

There are a few other good solutions on the gallery currently for sending these packets via Powershell.  My intent here was to combine some of the prominent features of them in a module that's compatible with Desktop and Core editions of PowerShell and cross platform.  Inspiration from [krzydoug](https://github.com/krzydoug/Tools/blob/master/Send-WakeOnLan.ps1), [ChrisWarwick](https://github.com/ChrisWarwick/WakeOnLan) and [NJ_Dude](https://www.powershellgallery.com/packages/PSWakeOnLAN/1.0.2).  

## Install

To install PSWoL
```Powershell
PS> Install-Module -Name 'PSWoL'
```  


## Use  

For most reliable operation it's best to specify the MAC address of the target you wish to 'wake'.  The -TargetAddress parameter accepts any input and attempts to derive if it's an IP address, Computer name, or MAC adddress. MAC addresses can be '1234.abde.4321', '12:34:AB:DE:43:21', '12-34-AB-DE-32-21' or '1234ABDE4321' format.
```Powershell
PS> Send-WakeOnLan -TargetAddress 00-0C-29-64-E6-63 -Verbose
VERBOSE: Performing the operation "Send WOL Packet" on target "00-0C-29-64-E6-63".
VERBOSE: Wake-on-LAN packet sent to target:00-0C-29-64-E6-63     MAC: 00-0C-29-64-E6-63

```
By comparison if you specify an IP address it will do its best to determine an associated MAC address.  
```Powershell
PS> Send-WakeOnLan -TargetAddress 192.168.12.15 -Verbose
VERBOSE: Performing the operation "Send WOL Packet" on target "192.168.12.15".
VERBOSE: Wake-on-LAN packet sent to target:192.168.12.15     MAC: 00-0C-29-64-E6-63

```
You can send multiple targets via the -TargetAddress parameter, or pipe input in from the pipeline.  
If you want to save a MAC address for future use and assign a name to it teh help functions Save/Get/Remove-WolTarget are available.  
### Save-WolTarget  
```Powershell
PS> Save-WolTarget -Name "Gibson" -MacAddress 'DC-A6-32-72-C0-E5'
```
### Get-WolTarget  
```Powershell
PS> Get-WolTarget -Name "Test"  
WARNING: No saved target found by name: Test

# don't provide any parameters and it will return all saved targets
PS> Get-WolTarget

Name                           Value
----                           -----
Gibson                         00-0C-29-64-E6-63
```
### Remove-WolTarget  
```Powershell
PS> Get-WolTarget

Name                           Value
----                           -----
Gibson                         00-0C-29-64-E6-63
Osiris                         6D:28:36:01:95:84

PS> Remove-WolTarget -Name Osiris
PS> Get-WolTarget

Name                           Value
----                           -----
Gibson                         00-0C-29-64-E6-63
# or delete them all
PS> Remove-WolTarget -DeleteAll

Confirm
Are you sure you want to perform this action?
Performing the operation "Remove-Item" on target "C:\Users\ZeroCool\AppData\Roaming\PSWoL\Settings.json".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

```

## Made With Sampler  
This project was made using [Sampler Module](https://github.com/gaelcolas/Sampler)  
See their [video presentation](https://youtu.be/tAUCWo88io4?si=jq0f7omwll1PtUsN) from the PowerShell summit for a great demontsration.  