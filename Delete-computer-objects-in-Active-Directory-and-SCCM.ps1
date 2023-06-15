<#
.SYNOPSIS


    Delete computer objects in Active Directory and SCCM(from Out-Gridview)

    User that runs the Scipts requirements:

    Permissions to delete computer object in Active Directory
    Permissions to delete computer object in SCCM

Version 1.0

.LINK 
    .Author Mikael Palmqvist 2023-06-14

#>

$SiteCode = "Your Site Code"  
$ProviderMachineName = "Your SMS Provider"
$initParams = @{}

if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}


if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

Set-Location "$($SiteCode):\" @initParams

$selectedComputers = Get-ADComputer -Filter * | Select-Object Name | Out-GridView -OutputMode Multiple -Title "Select Computers to Delete"

try {
    foreach ($computer in $selectedComputers) {
        $computerName = $computer.Name
        Write-Host "Deleting computer '$computerName' from Active Directory..." -ForegroundColor Yellow
        Remove-ADComputer -Identity $computerName -Confirm:$false -ErrorAction Stop
    }

    foreach ($computer in $selectedComputers) {
        $computerName = $computer.Name

         try{
        if (@(Get-CMDevice -Name $computerName -ErrorAction SilentlyContinue).Count)
        {
            Write-Host "Remove computer '$computerName' in SCCM..." -ForegroundColor Yellow
            Get-CMDevice -Name $computerName | Remove-CMDevice -Force
        }
        else
        {
        }
    }catch{

    }
    Write-Host "The computer '$computerName' is not in SCCM..." -ForegroundColor Green      
   }
    
    Write-Host "Process completed successfully." -BackgroundColor Black
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Cyan

 

}

Set-Location "C:\"