<#
.SYNOPSIS

    .DESCRIPTION
    Get Intune devices and hardware infromation in a csv file
    By Mikael Palmqvist, Gohhybrid AB, 2023-04-05


#>
Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion beta -Quiet

$ExportPath = "c:\windows\Temp\Mijks\$((Get-Date).ToString('yyyy-mm-dd HHmmss')) IntuneHWInventory.csv"

$Devices = Get-IntuneManagedDevice | Where-Object {$_.DeviceName -like "Desktop*" -and $_.operatingsystem -eq "Windows"}

if($Devices){
    $Results = @()
    foreach($Device in $Devices){
    $DeviceID = $Device.id
    #Write-Host "Device found:" $Device.deviceName -ForegroundColor Yellow
    $uri = "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$DeviceID')?`$select=hardwareinformation,iccid,udid,ethernetMacAddress"
    $DeviceInfo = Invoke-MSGraphRequest -Url $uri -HttpMethod Get
    $DeviceNoHardware = $Device | select * -ExcludeProperty hardwareInformation,deviceActionResults,userId,imei,manufacturer,model,isSupervised,isEncrypted,serialNumber,meid,subscriberCarrier,iccid,udid,ethernetMacAddress
    $HardwareExcludes = $DeviceInfo.hardwareInformation | select * -ExcludeProperty sharedDeviceCachedUsers,phoneNumber
    $OtherDeviceInfo = $DeviceInfo | select iccid,udid,ethernetMacAddress

        $Object = New-Object System.Object
            foreach($Property in $DeviceNoHardware.psobject.Properties){
                $Object | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value

            }
            foreach($Property in $HardwareExcludes.psobject.Properties){
                $Object | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value
            }

            foreach($Property in $OtherDeviceInfo.psobject.Properties){
                $Object | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value
            }
        $Results += $Object
        $Object
    }
    $Date = get-date
    $Output = "ManagedDeviceHardwareInfo_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + "_" + $Date.Hour + "-" + $Date.Minute
    $Results | Export-Csv -LiteralPath $ExportPath
    Write-host "Done with getting Intune hardware infromation on devices and created '$ExportPath' file" -ForegroundColor Yellow 
}

else {

write-host "No Intune Managed Devices found..." -f green
Write-Host

}
