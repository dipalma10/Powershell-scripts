<#
.SYNOPSIS

 Powershell script to used for create Hyper-V(s) that will be Enrolled in Intune Automatically
 Pre-Req 
 Using App Registation in Azure and get the -TenantId -AppId -AppSecret 
 Make an Windows 10 vhdx file and sysprep
 
 Created by Mikael Palmqvist, 2011-09-12
 Revision 0.9
 
.Author Mikael Palmqvist 2023-01-01

#>

Clear-host 
$HypervHost = "SRV01"
$greenCheck = @{
  Object = [Char]8730
  ForegroundColor = 'green'
  NoNewLine = $true
}
# Variables to be changed for your environment
$TenantId = ""
$AppId = ""
$AppSecret =""
$ParentPath = "F:\Hyper-V\Win10Ref\Virtual Hard Disks\Win10Ref.vhdx"
$CountOfVM = "1"

    # The local account when sysprepped the machine
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList labadmin, (ConvertTo-SecureString "BlaBlaBla" -AsPlainText -Force)

    function waitForPSDirect([string]$VMName, $cred){
    Write-Output "[$($VMName)]:: Waiting for PowerShell Direct (using $($cred.username))"
    while ((icm -VMName $VMName -Credential $cred {"Test"} -ea SilentlyContinue) -ne "Test") {Sleep -Seconds 1}
    }

1..$CountOfVM | % {

    $VMName = "MEMVM-LAB112-$_"

    Write-Host "Create VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y

    New-VHD -Path "F:\ClusterStorage\Volume1\$VMName\$VMName.vhdx" -ParentPath $ParentPath -Differencing | Out-Null
    Write-Host "Create vhdx Disk for VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    New-VM -Name $VMName -MemoryStartupBytes 4GB -SwitchName WWW -Path F:\ClusterStorage\Volume1\$VMName -Generation 1 | Out-Null
    Write-Host "Create VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Set-VM -Name $VMName -ProcessorCount 2
    Write-Host "Set 2 CPU nn $VMName : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y

    Add-VMHardDiskDrive -VMName $VMName -ControllerType IDE -ControllerNumber 0 -Path "F:\ClusterStorage\Volume1\$VMName\$VMName.vhdx"
    Write-Host "ADD VHDX disk to VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Enable-VMIntegrationService –Name "Guest Service Interface" -VMName $VMName
    Write-Host "Enable 'Guest Service Interface' on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y
     
    Start-VM $VMName 
    Write-Host "Now when configuration is finished on VM '$VMName' time to boot it up : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Write-Host "Waiting for Powershell Direct is ready on VM '$VMName' : " -ForegroundColor Y -NoNewline
    waitForPSDirect -VMName $VMName -cred $cred  | Out-Null
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Get-VMIntegrationService -VMName $VMName -Name "Time Synchronization" | Enable-VMIntegrationService
    Write-Host "Running 'Time Synchronization' on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Enter-PSSession -VMName $VMName -Credential $cred

    Powershell Set-ExecutionPolicy bypass -Force | Out-Null
    #Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Powershell Set-ExecutionPolicy bypass -Force} | Out-Null
    Write-Host "Running Powershell Set-ExecutionPolicy bypass -Force on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Install-PackageProvider -Name NuGet -Confirm:$false -Force:$true | Out-Null
    #Invoke-Command -VMName $VMName -ScriptBlock {Install-PackageProvider -Name NuGet -Confirm:$false -Force:$true} | Out-Null
    Write-Host "Running Install-PackageProvider -Name NuGet on VM '$VMName' time to boot it up : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y 

    Install-Script Get-WindowsAutopilotInfo -Confirm:$false -Force:$true | Out-Null
    #Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Install-Script Get-WindowsAutopilotInfo -Confirm:$false -Force:$true} | Out-Null
    Write-Host "Running Install-Script Get-WindowsAutopilotInfo on VM '$VMName' : " -F y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y 

    set-timezone "W. Europe Standard Time" | Out-Null
    #Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {set-timezone "W. Europe Standard Time"} | Out-Null
    Write-Host "Running 'Set timezone(W. Europe Standard Time)' on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    #
    # Add Dummy GroupTag to be able to force a device sync. To be changed. Mijk 
    #
    
    Get-WindowsAutopilotInfo -Grouptag Dummy -Online -TenantId $TenantId -AppId $Appid -AppSecret $AppSecret | Out-Null
    Write-Host "Running 'Get-windowsautopilotinfo' on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    $Ser = Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | ? {$_.elementName -eq $VMName} | Select -ExpandProperty BIOSSerialNumber
    Write-Host "Running 'Get Serial number ($ser)' on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    $ProfileStatus = Get-AutopilotDevice -serial $Ser | select deploymentProfileAssignmentStatus

    Do
    {
    write-host "Wait for device with serial number -> '$ser' to be assigned a Autopilot Profile" -ForegroundColor Gray
    $ProfileStatus = Get-AutopilotDevice -serial $Ser | select deploymentProfileAssignmentStatus
    Start-Sleep -Seconds 240
    } Until ($ProfileStatus.deploymentProfileAssignmentStatus -eq "assignedUnkownSyncState")
    Write-Host "Device '$ser' Assigned to Autopilot Profile '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Write-Host "Added GroupTag to '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Shutdown -f -r -t 15} | Out-Null
    Write-Host "Need to reboot the VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

    Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Enable-NetFirewallRule -DisplayGroup "Remote Desktop"} | Out-Null
    Write-Host "Enabled RPD on VM '$VMName' : " -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y

}


