###########################################################################################
#
# PS used for create many VM's that will be Enrolled in MEM(forme Intune) Automatically
#
# Using App Registation in Azure
# 
# Created by Mikael Palmqvist, Gohybrid AB, 2011-09-12
#
# Revision 0.9
#
#
###########################################################################################
Clear-host 
$TenantId = "e91cdf8b-9248-4fc8-b057-0921ssji6aa53747" 
$AppId = "Blablabla"
$AppSecret = "Blablabla" 
$clientId = "Blablabla"
$clientSecret = "Blablabla" 
$ourTenantId = "Blablabla"
$Resource = "deviceManagement/managedDevices"
$graphApiVersion = "Beta"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
$authority = "https://login.microsoftonline.com/$ourTenantId"
Update-MSGraphEnvironment -AppId $clientId -Quiet
Update-MSGraphEnvironment -AuthUrl $authority -Quiet
Connect-MSGraph -ClientSecret $clientSecret 
############ $HypervHost = "SRV01" $greenCheck = @{
  Object = [Char]8730
  ForegroundColor = 'green'
  NoNewLine = $true
} $CountOfVM = "2"     $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList TheDude, (ConvertTo-SecureString "12345QW12345" -AsPlainText -Force)     function waitForPSDirect([string]$VMName, $cred){
    Write-Output "[$($VMName)]:: Waiting for PowerShell Direct (using $($cred.username))"
    while ((icm -VMName $VMName -Credential $cred {"Test"} -ea SilentlyContinue) -ne "Test") {Sleep -Seconds 1}} 1..$CountOfVM | % {     $VMName = "MEMVM-VM-$_"     Write-Host "Create VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y     New-VHD -Path "D:\ClusterStorage\Volume1\$VMName\$VMName.vhdx” -ParentPath "D:\ClusterStorage\Volume1\Hard Disk.vhdx" -Differencing | Out-Null
    Write-Host "Create vhdx Disk for VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y 
    New-VM -Name $VMName -MemoryStartupBytes 4GB -SwitchName WWW -Path D:\ClusterStorage\Volume1\$VMName -Generation 1 | Out-Null
    Write-Host "Create VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Set-VM -Name $VMName -ProcessorCount 2
    Write-Host "Set 2 CPU nn $VMName : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y     Add-VMHardDiskDrive -VMName $VMName -ControllerType IDE -ControllerNumber 0 -Path "D:\ClusterStorage\Volume1\$VMName\$VMName.vhdx”
    Write-Host "ADD VHDX disk to VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Enable-VMIntegrationService –Name "Guest Service Interface" -VMName $VMName
    Write-Host "Enable 'Guest Service Interface' on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -F Y
    Start-VM $VMName 
    Write-Host "Now when configuration is finished on VM '$VMName' time to boot it up : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Write-Host "Waiting for Powershell Direct is ready on VM '$VMName' : ” -ForegroundColor Y -NoNewline
    waitForPSDirect -VMName $VMName -cred $cred  | Out-Null
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Install-PackageProvider -Name NuGet -Confirm:$false -Force:$true} | Out-Null
    Write-Host "Running Install-PackageProvider -Name NuGet on VM '$VMName' time to boot it up : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Install-Script Get-WindowsAutopilotInfo -Confirm:$false -Force:$true} | Out-Null
    Write-Host "Running Install-Script Get-WindowsAutopilotInfo on VM '$VMName' : ” -F y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Powershell Set-ExecutionPolicy bypass -Force} | Out-Null
    Write-Host "Running Powershell Set-ExecutionPolicy bypass -Force on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {set-timezone "W. Europe Standard Time"} | Out-Null
    Write-Host "Running 'Set timezone(W. Europe Standard Time)' on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Get-VMIntegrationService -VMName $VMName -Name "Time Synchronization" | Enable-VMIntegrationService
    Write-Host "Running 'Time Synchronization' on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     #
    # Add Dummy GroupTag to be able to force a device sync. To be changed. Mijk 
    #
    Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Get-WindowsAutopilotInfo -Grouptag Dummy -Online -TenantId e91cdf8b-9248-4fc8-b057-09216aa53747 -AppId 48b49baf-16f4-45c1-9616-595fda1a4fb2 -AppSecret 4HE8Q~NUOkYQwnwQg2TM1Tk.W5kockyhHBKCCc.6} | Out-Null
    Write-Host "Running 'Get-windowsautopilotinfo' on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     $Ser = Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | ? {$_.elementName -eq $VMName} | Select -ExpandProperty BIOSSerialNumber
    Write-Host "Running 'Get Serial number ($ser)' on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y         $TenantId = "e91cdf8b-9248-4fc8-b2121057-09216aa53747" 
        $AppId = "Blablabla"
        $AppSecret = "Blablabla"         
	  $clientId = "Blablabla" #Provide the Client ID
        $clientSecret = "Blablabla" # Provide the ClientSecret
        $ourTenantId = "Blablabla" #Specify the TenatID         
        $Resource = "deviceManagement/managedDevices"
        $graphApiVersion = "Beta"
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
        $authority = "https://login.microsoftonline.com/$ourTenantId"
        Update-MSGraphEnvironment -AppId $clientId -Quiet
        Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $clientSecret     $ProfileStatus = Get-AutopilotDevice -serial $Ser | select deploymentProfileAssignmentStatus     Do
    {
    write-host "Wait for device with serial number -> '$ser' to be assigned a Autopilot Profile" -ForegroundColor Gray
    $ProfileStatus = Get-AutopilotDevice -serial $Ser | select deploymentProfileAssignmentStatus
    #$ProfileStatus
    #$ProfileStatusr++
    Start-Sleep -Seconds 240
    } Until ($ProfileStatus.deploymentProfileAssignmentStatus -eq "assignedUnkownSyncState")
    #"Done is Assigned"
    Write-Host "Device '$ser' Assigned to Autopilot Profile '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     #Set-AutopilotDevice -
    #Set-AutopilotDevice -id $ser -GroupTag "HR"
    Write-Host "Added GroupTag to '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Shutdown -f -r -t 15} | Out-Null
    Write-Host "Need to reboot the VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y     Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock {Enable-NetFirewallRule -DisplayGroup "Remote Desktop"} | Out-Null
    Write-Host "Enabled RPD on VM '$VMName' : ” -F Y -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)" -f Y }