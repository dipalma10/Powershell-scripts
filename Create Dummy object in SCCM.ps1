<#
.SYNOPSIS

 Create Dummy object in SCCM

.LINK 
	.Author

    Mikael Palmqvist, 2023-01-07

    Version 1.0

Download the Windows ADK for Windows 11, version 22H2 -> https://go.microsoft.com/fwlink/?linkid=2196127
Download the Windows PE add-on for the Windows ADK for Windows 11, version 22H2 -> https://go.microsoft.com/fwlink/?linkid=2196224


#>

New-SelfSignedCertificate -Type Custom -Subject "CN=CmDeviceSeed ISV Proxy Certificate" -KeyLength 2048 -KeySpec KeyExchange -KeyExportPolicy Exportable -FriendlyName "CmDeviceSeed ISV Proxy Certificate" -CertStoreLocation "cert:\LocalMachine\My"

Get-ChildItem -Path Cert:\<PATH>\ | where{$_.Thumbprint -eq "CmDeviceSeed ISV Proxy Certificate"} | Export-PfxCertificate -FilePath c:\

$siteCode = "CT1"
 $clientCount = 10
 $clientStartNumber = 1
 $clientPrefix = "WS"

 $modulePath = 'F:\CMDeviceSeed\Microsoft.ConfigurationManagement.Messaging.dll'
 $adminconsolePath = 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
 Import-Module –Name $modulePath 
 Import-Module –Name $adminconsolePath
 Set-Location $siteCode":"  

function CreateMACAddress()
{
    [int]$len = 12
    [string] $chars = "0123456789ABCDEF"
    $bytes = new-object "System.Byte[]" $len
    $rnd = new-object System.Security.Cryptography.RNGCryptoServiceProvider
    $rnd.GetBytes($bytes)
    $macraw = ""
    for( $imac=0; $imac -lt $len; $imac++ )
    {
        $macraw += $chars[ $bytes[$imac] % $chars.Length ]
    }
    $macaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]
    Return $macaddress
}

 function CreateDDREntry()
 {
    param([string]$siteCode, [string]$computerName, [string]$MACAddress)
    [string[]] $macaddresses = $MACAddress
    $agentName = 'CMDeviceSeed Client Generator'
    $ddr = New-Object -typename Microsoft.ConfigurationManagement.Messaging.Messages.Server.DiscoveryDataRecordFile -ArgumentList $agentName
    $ddr.SiteCode = $siteCode
    $ddr.Architecture = 'System'
    $ddr.AddStringPropertyArray('MAC Addresses', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::Array, 17, $macaddresses)
    $ddr.AddIntegerProperty('Active', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::None, 1)
    $ddr.AddIntegerProperty('Client', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::None, 1)
    $ddr.AddIntegerProperty('Client Type', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::None, 1)
    $ddr.AddStringProperty('Operating System Name and Version', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::None, 128, "Microsoft Windows NT Workstation 6.3")
    $ddr.AddStringProperty('Name', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::Key -bor [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::Name, 32, $computerName)
    $ddr.AddStringProperty('Netbios Name', [Microsoft.ConfigurationManagement.Messaging.Messages.Server.DdmDiscoveryFlags]::Name, 16, $computerName)
    $ddr.SerializeToInbox()
    Return $true
 }

 for($i=$clientStartNumber; $i -le ($clientCount + $clientStartNumber -1); $i++)
 {
    [string]$mac = CreateMACAddress
    $iformat = "{0:D6}" -f $i
    [string]$name = $clientPrefix+$iformat
    Write-Host "Creating computer"$name "("$mac")"
    Import-CMComputerInformation -ComputerName $name -MacAddress $mac
    CreateDDREntry -siteCode $siteCode -computerName $name -MACAddress $mac
 }
