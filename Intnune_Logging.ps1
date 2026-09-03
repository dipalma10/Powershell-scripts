Created By Mikael Palmqivist, Contribit AB
<#
.SYNOPSIS

    Test PS 4 Intune and loggning.

.DESCRIPTION

    This script will...
	
.NOTES

    FileName:    Invoke-MSIntuneDriverUpdate.ps1
    Author:      Mikael Palmqvist
#>

$env:computername
$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$env:computername.log"
 
function WriteLog

    {

        Param ([string]$LogString)
        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        $LogMessage = "$Stamp $LogString"
        Add-content $LogFile -value $LogMessage

    }

WriteLog "It works.... :-)"
