$PC_Inv_File = $env:TEMP + "\" + "PC-inventering-" + $Env:COMPUTERNAME + ".csv"
$SourceFile = $PC_Inv_File
#$TargetFile = "\\UNCPATH\Inventory$\Computers"

$Results = @()

$Computer  = $Env:COMPUTERNAME
$env = $Env:Temp

    $strFilter = "(&(objectCategory=User)(samAccountName=$($env:USERNAME)))"
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = $objDomain
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = $strFilter
    $objSearcher.SearchScope = "Subtree"

    $colProplist = "*"
    foreach($i in $colPropList){$status = $objSearcher.PropertiesToLoad.Add($i)}


    try {

        $colResults = $objSearcher.FindAll()
        
        write-host "Connected to a Domain" -ForegroundColor Yellow
        
        }
        catch {
        write-host "Unable to connect to a domain, must be a workgroup" -ForegroundColor Yellow
    }

    foreach ($objResult in $colResults)
        {
        $objItem = $objResult.Properties
        $mail = $objResult.properties.mail[0].SubString(0)
        $samaccountname = $objResult.properties.samaccountname[0].SubString(0)
        }
         

    ForEach ($Computer in $Computer)
        {
            $Properties = @{
        
            Date = $DateTime = (Get-Date).ToString('yyyy-MM-dd')
            Time = (Get-Date).ToString('HH:mm:ss')
            ComputerName = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer | select -ExpandProperty CSName
            UserName = $samaccountname
            UserID = $samaccountname
            MailAddress = $mail
            IPAddress = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" -ComputerName $Computer | where { $_.ipaddress -like "1*" } | select -ExpandProperty ipaddress | select -First 1
            SerialNumber = gwmi win32_bios | Select –ExpandProperty SerialNumber
            OSVersion = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer | Select-Object -ExpandProperty Caption 
            OSInstalldate = gcim Win32_OperatingSystem | select –ExpandProperty InstallDate
            BIOSVersion = gwmi win32_bios | Select –ExpandProperty SMBIOSBIOSVersion
            Workgroup = (Get-WmiObject -Class Win32_ComputerSystem).Workgroup
            Domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
        }
            $Results += New-object psobject -Property $Properties
    }

    $filepath = $PC_Inv_File
    $contents = Get-Content -path $filepath -Force -ErrorAction SilentlyContinue
    
    $contentFound = $false
    foreach ($content in $contents) {
        
        if ($content -like "*$($Properties.UserName)*" -and $content -like "*$($Properties.computername)*") {
            
            $newcontent = ($Results | Select-Object Date,Time,ComputerName,UserName,UserID,MailAddress,IPAddress,SerialNumber,OSVersion,OSInstalldate,BIOSVersion,Workgroup,Domain | ConvertTo-csv)[2]
            
            (Get-Content $filepath).Replace($content, $newcontent) | set-content $filepath

        $contentFound = $true
        } 
    }

    if (!$contentFound) {
        $Results | Select-Object Date,Time,ComputerName,UserName,UserID,MailAddress,IPAddress,SerialNumber,OSVersion,OSInstalldate,BIOSVersion,Workgroup,Domain | Export-csv -Path $PC_Inv_File -NoTypeInformation -Append
    }

## Copy file

$ValidPath = Test-Path -Path $TargetFile

If ($ValidPath -eq $False){

    Write-host "The patch is not valid!" -ForegroundColor Red
} else {
      Copy-Item $SourceFile -Destination $TargetFile -Recurse -force
}

