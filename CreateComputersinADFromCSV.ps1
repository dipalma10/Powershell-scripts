<#
.SYNOPSIS

    Create computer objects in Active Directory

 Version 1.0
 
.LINK 
	.Author Mikael Palmqvist 2023-06-14

#>


$CSV = Get-Content 'C:\Users\labadmin\Desktop\cvscomputersAD.csv'
try {
    foreach ($computer in $CSV) {
        $computerName = $computer.Name
        $templateComp = get-adcomputer "VMPR2" -properties "Location","OperatingSystem","OperatingSystemHotfix","OperatingSystemServicePack","OperatingSystemVersion"
        New-ADComputer -Instance $templateComp -Name $Computer -Path $OU -Enabled $True -WarningAction SilentlyContinue
        Write-Host "Created computer '$computer' in Active Directory..." -ForegroundColor Yellow
    }

    foreach ($computer in $selectedComputers) {
        $computerName = $computer.Name
        Write-Host "Remove computer '$computerName' in SCCM..." -ForegroundColor Yellow
     #   Get-CMDevice -Name $computerName | Remove-CMDevice -Force
    }

    Write-Host "Process completed successfully."
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Cyan

}
