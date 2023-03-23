<#
.SYNOPSIS

Get all devices from group and select the once you want to remove

Mikael Palmqvist, Gohybrid AB, 2023-03-22
    Version 0.1

    Connect-AzureAD

#>



# Check if AzureAD module is installed
if (Get-Module -Name AzureAD -ListAvailable) {
    Write-Host "AzureAD module is installed." -ForegroundColor Green
    Write-Host "Description: The AzureAD PowerShell module is used to manage Azure Active Directory resources." -ForegroundColor Green
} else {
    Write-Host "Installing AzureAD module..." -ForegroundColor Red
    Install-Module AzureAD -Force
}


try {

    $groups = Get-AzureADGroup
    $selectedGroup = $groups | Out-GridView -Title "Select a group Azure/Intune" -OutputMode Single

    Write-Host "Selected group: '$($selectedGroup.DisplayName)'" -ForegroundColor Yellow
    
    $devices =  Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true
    $selectedDevice = $devices | Out-GridView -Title "Select a device to remove" -OutputMode Multiple

    Write-Host "Selected group: '$($selectedDevice.DisplayName)'" -ForegroundColor Yellow

    Foreach ($Item in $selectedDevice) {

    #Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $selectedDevice.ObjectId -ErrorAction SilentlyContinue -Verbose
    $updatedDevices = Get-AzureADGroupMember -ObjectId $group.ObjectId

    Write-Host "Device '$($selectedDevice.DisplayName)' removed from '$($selectedGroup.DisplayName)'" -ForegroundColor Yellow

    }
}
catch {
    Write-Error "Error occurred: $($_.Exception.Message)"
}

