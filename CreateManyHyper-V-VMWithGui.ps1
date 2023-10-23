<#
.SYNOPSIS

 Create a VHDX VM for windows 10 make a sysprep, put unattend.xml in C:\windows\system32\sysprep
 that sets the local password
 Version 1.0
 Version 1.1 this version will have parameters, for how many VM, VM RAM, VM CPU, path to diff vhdx file, etc 

To be added 
param (
    [string]$VMSuffix = $( Read-Host "VM Suffix"),
    [string]$CountOfVM = $( Read-Host "How many VM"), 
    [string]$CPU = $( Read-Host "How many CPU"),    
    [string]$MEM = $( Read-Host "Amount of RAM"),
    [string]$PathVHDXDif = $( Read-Host "Path to VHDX Diff file"),
    [switch]$SaveData = $false
)

$VMSuffix
$CountOfVM
$CPU
$MEM 
$PathVHDXDif

.LINK 
	.Author Mikael Palmqvist 2020-01-01
#>

function Start-CreateForm 
{ 
 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "My Form"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.AutoSize
$form.StartPosition = "CenterScreen"
#$Form.ControlBox = $False

    # Check for ENTER and ESC presses
    $Form.KeyPreview = $True
    $Form.Add_KeyDown({if ($PSItem.KeyCode -eq "Enter") 
        {
        # if enter, perform click
        $OKButton.PerformClick()
        }
    })
    $Form.Add_KeyDown({if ($PSItem.KeyCode -eq "Escape") 
        {
        # if escape, exit
        Write-host "1"
        $Form.Close()
        Write-host "2"
        Exit
        }
    })


# Create dropdown
$dropdown = New-Object System.Windows.Forms.ComboBox
$dropdown.Location = New-Object System.Drawing.Point(20, 20)
$dropdown.Width = 200
$dropdown.Items.AddRange(@("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"))
$form.Controls.Add($dropdown)

# Create label boxes
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(20, 60)
$label1.Text = "VM Suffix"
$form.Controls.Add($label1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(20, 90)
$label2.Text = "Local Account"
$form.Controls.Add($label2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(20, 120)
$label3.Text = "Local password"
$form.Controls.Add($label3)

$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(20, 150)
$label4.Text = "Domain Account"
$form.Controls.Add($label4)

$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(20, 180)
$label5.Text = "Domain password"
$form.Controls.Add($label5)

$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(20, 210)
$label5.Text = "Domain to join"
$form.Controls.Add($label5)

# Create text boxes
$textbox1 = New-Object System.Windows.Forms.TextBox
$textbox1.Location = New-Object System.Drawing.Point(120, 60)
$textbox1.Text = "Hybrid"
$form.Controls.Add($textbox1)

$textbox2 = New-Object System.Windows.Forms.TextBox
$textbox2.Location = New-Object System.Drawing.Point(120, 90)
$textbox2.Text = "Labadmin"
$form.Controls.Add($textbox2)

$textbox3 = New-Object System.Windows.Forms.TextBox
$textbox3.Location = New-Object System.Drawing.Point(120, 120)
$textbox3.PasswordChar = "*"
$form.Controls.Add($textbox3)

$textbox4 = New-Object System.Windows.Forms.TextBox
$textbox4.Location = New-Object System.Drawing.Point(120, 150)
$textbox4.Text = "Labadmin"
$form.Controls.Add($textbox4)

$textbox5 = New-Object System.Windows.Forms.TextBox
$textbox5.Location = New-Object System.Drawing.Point(120, 180)
$textbox5.PasswordChar = "*"
$form.Controls.Add($textbox5)

$textbox6 = New-Object System.Windows.Forms.TextBox
$textbox6.Location = New-Object System.Drawing.Point(120, 210)
$textbox6.Text = "Mijsdemolab"
$form.Controls.Add($textbox6)

# Create Save button
$Savebutton = New-Object System.Windows.Forms.Button
$Savebutton.Location = New-Object System.Drawing.Point(20, 240)
$Savebutton.Text = "Save"
$form.Controls.Add($savebutton)

# Create label box to display form status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10,290)
$statusLabel.Size = New-Object System.Drawing.Size(100, 350)
$form.Controls.Add($statusLabel)

# Create Reload button
$reloadButton = New-Object System.Windows.Forms.Button
$reloadButton.Location = New-Object System.Drawing.Point(120, 300)
$reloadButton.Text = "Reload"
$reloadButton.Add_Click({
    Clear-Form
})
$form.Controls.Add($reloadButton)

# Create Exit button
$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Location = New-Object System.Drawing.Point(120, 325)
$ExitButton.Text = "Exit"
$ExitButton.Add_Click({

Exit
$form.Close()

})
$form.Controls.Add($ExitButton)

# Function to clear the textboxes
function Clear-Form(){

$dropdown.SelectedItem = ""
$TextBox1.text= "Hybrid"
$TextBox2.text= "Labadmin"
$TextBox3.text= ""
$TextBox4.text= "Labadmin"
$TextBox5.text= ""
$TextBox6.text= "dudesdemolab"
}

$Savebutton.Add_Click({

$VMCount = $dropdown.SelectedItem

    $status = ""
    $status = "Values saved: "
    $status += "How many VM(s)", $VMCount, $textbox1.Text, $textbox2.Text, $textbox3.Text, $textbox4.Text, $textbox5.Text, $textbox5.Text
    $statusLabel.Text = $status
    #write-host "Status -> " $status -ForegroundColor y
   # $form.Close()
   
1..$VMCount | % {

    #$VMName = "$($Textbox1.text)$_”
    $VMName = "$($Textbox1.text)$_”
    Write-Host "Set VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Write-Host -Verbose "Set variable How many VM: '$VMCount' : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Write-Host -Verbose "Set variable Domain to use -> '$($Textbox6.text)' : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    $localCred = new-object -typename System.Management.Automation.PSCredential -argumentlist "labadmin”, (ConvertTo-SecureString "Sommar2021!” -AsPlainText -Force)
    Write-Host "Encrypt local password : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    $domainCred = new-object -typename System.Management.Automation.PSCredential -argumentlist "nnnnnnnnn\admin", (ConvertTo-SecureString "nnnnnnnn" -AsPlainText -Force)
    Write-Host "Encrypt domain password : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    $SubMaskBit = "24"
    Write-Host "User Subnet '$SubMaskBit' : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    $DNSServers = "192.168.1.200"
    Write-Host "Set variable DNS Server '$DNSServers' : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    $IP = "192.168.1.21$_"

    
    function rebootVM([string]$VMName) { Write-Output "[$($VMName)]:: Is Rebooting"; stop-vm $VMName; start-vm $VMName }
    Write-Host "Set function 'RebootVM' : " -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    New-VHD -Path "G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx” -ParentPath "F:\Hyper-V\Win10Ref\Virtual Hard Disks\Win10Ref.vhdx" -Differencing | Out-Null
    Write-Host "Create vhdx Disk for VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    New-VM -Name $VMName -MemoryStartupBytes 1gb -SwitchName CORP -Path G:\ClusterStorage\Volume1\$VMName -Generation 1 | Out-Null
    Write-Host "Create VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Add-VMNetworkAdapter -VMName $VMName
    Write-Host "Add a second newtwork adapter '$VMName'(Not Connected) : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Write-Host "Set VM memory on $VMName : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Add-VMScsiController -VMName $VMName
    Write-Host "Add VMSCSIController on '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Add-VMHardDiskDrive -VMName $VMName -ControllerType IDE -ControllerNumber 0 -Path "G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx”
    Write-Host "ADD VHDX disk tp VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"
   
    Mount-VHD "G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx”
    Write-Host "Mount VHDX 'G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

#    Copy-Item "G:\Lab\AutopilotConfigurationFile.json" -destination "F:\Windows\Provisioning\Autopilot\"
#    Write-Host "'Copy Autopilot Configuration File file VM' to VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
#    Start-Sleep -Seconds 1
#    Write-Host @greenCheck
#    Write-Host " (Done)"

    Enable-VMIntegrationService –Name "Guest Service Interface" -VMName $VMName
    Write-Host "Enable 'Guest Service Interface' on VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Dismount-VHD "G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx”
    Write-Host "Dismount 'G:\ClusterStorage\Volume1\$VMName\$VMName.vhdx' on VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Set-VM -Name $VMName -CheckpointType Disabled
    Write-Host "Disable checkpoint on VM '$VMName' : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    #start-vm $VMName
    Write-Host "Now when configuration is finished on VM '$VMName' time to boot it up : ” -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host @greenCheck
    Write-Host " (Done)"

    Write-host "------------------------------------------------------------------------------------" 

    }
}

)

$form.Controls.Add($button)

# Show form
$form.ShowDialog()

function waitForPSDirect([string]$VMName, $cred)
    {
    Write-host "[$($VMName)]:: Waiting for PowerShell Direct (using $($cred.username))” -ForegroundColor Yellow
    while ((Invoke-Command -VMName $VMName -Credential $cred -ScriptBlock { "Test” } -ea SilentlyContinue) -ne "Test") { Sleep -Seconds 1 }
}

#Write-Host "Set function 'WaitForPSDirect' : " -ForegroundColor Yellow -NoNewline
#Start-Sleep -Seconds 1
#Write-Host @greenCheck
#Write-Host " (Done)"

$greenCheck = @{
  Object = [Char]8730
  ForegroundColor = 'green'
  NoNewLine = $true
  }

#$VMCount = 1
#$domain = "dudesdemolab.com"
}
Start-CreateForm
