<#
.SYNOPSIS
 Move Clsuter Role to another Node before patchning
 Version 0.2
 .LINK 
 .Author Mikael Palmqvist 2023-01-01
#>
Start-Transcript C:\Windows\temp\OrchestratePre.log

try {
    $roleName = "NewRole"
    $currentOwner = "Cluster3"
    $targetOwner = "Cluster2"
    #$clusterGroup = Get-ClusterGroup -Name $roleName
    #$clusterNode = Get-ClusterNode $nodeName

    if ($clusterGroup.OwnerNode.Name -eq $currentOwner) {
      
        Move-ClusterGroup -Name $roleName -Node $targetOwner # - -FailoverType Move
        Write-Host "The $roleName cluster role has been moved from $currentOwner to $targetOwner." -ForegroundColor Yellow
        if ($clusterNode.State -eq "Up") {
            Suspend-ClusterNode "Cluster1" -Cluster "Mijkscluster"
            Write-Host "The '$targetOwner' node is being drained. Roles and resources are being moved to other available nodes." -ForegroundColor Yellow
        }
        else {
            Write-Host "The '$targetOwner' node is already offline or in the process of being taken offline." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "The $roleName cluster role is not currently owned by $currentOwner." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "An error occurred while moving the cluster role: $_" -ForegroundColor Yellow
}

Stop-Transcript
