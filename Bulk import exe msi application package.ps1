<#
.SYNOPSIS

Bulk import exe msi application package

.LINK 
	.Author

    Mikael Palmqvist, Gohybrid AB, 2023-03-22

    Version 0.1

    Connect-AzureAD

#>



# Set the path where the Win32 apps are located
$Path = "C:\Win32Apps"

try {
    # Get the list of applications from the specified path and recursive folders
    $Apps = Get-ChildItem $Path -Recurse -Include *.exe,*.msi | Select-Object FullName, Name

    # Loop through each application and create an Intune group based on the application name
    foreach ($App in $Apps) {
        $AppName = $App.Name.Replace(".exe", "").Replace(".msi", "")
        $GroupDisplayName = "Intune Group for $AppName"

        # Check if the group already exists
        if (!(Get-IntuneGroup -DisplayName $GroupDisplayName)) {
            # Create the Intune group
            $Group = New-IntuneGroup -DisplayName $GroupDisplayName

            Write-Host "Created Intune group for $AppName with ID $($Group.Id)"
        }
        else {
            Write-Host "Intune group for $AppName already exists"
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
}
