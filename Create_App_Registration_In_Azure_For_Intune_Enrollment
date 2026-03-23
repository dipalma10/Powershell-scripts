# ================================
# 
# Created by Mikael Palmqvist, 2026-03-23
#
# Check PowerShell 7+ version
#
#
# ================================
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "PowerShell 7 is required. Installing..."

    $isWindows = $env:OS -eq "Windows_NT"

    if ($isWindows) {
        # Check if winget exists
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Installing PowerShell 7 using winget..."
            winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
        }
        else {
            Write-Host "winget not found. Please install PowerShell 7 manually:"
            Write-Host "https://aka.ms/powershell-release?tag=stable"
        }

        # Relaunch script in pwsh
        $pwshPath = "pwsh.exe"

        if (Get-Command $pwshPath -ErrorAction SilentlyContinue) {
            Write-Host "Restarting script in PowerShell 7..."
            & $pwshPath -File $PSCommandPath
        }
        else {
            Write-Host "PowerShell 7 installed but not found in PATH. Please restart your terminal."
        }
    }
    else {
        Write-Host "Non-Windows OS detected. Please install PowerShell 7 manually."
    }
}

# ================================
# Install Microsoft Graph Module
# ================================
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Installing Microsoft Graph module..."
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

Import-Module Microsoft.Graph

# ================================
# Connect to Microsoft Graph
# ================================
Connect-MgGraph -Scopes "Application.ReadWrite.All","Directory.ReadWrite.All"

# ================================
# Variables
# ================================
$appName = "Intune-Device-Enrollment-App"
$tenantId = (Get-MgContext).TenantId

# ================================
# Create App Registration
# ================================
$app = New-MgApplication -DisplayName $appName

# Create Service Principal
$sp = New-MgServicePrincipal -AppId $app.AppId

# Microsoft Graph App ID
$graphAppId = "00000003-0000-0000-c000-000000000000"

# Required Permissions
$permissions = @(
    "DeviceManagementManagedDevices.ReadWrite.All",
    "DeviceManagementServiceConfig.ReadWrite.All",
    "Device.ReadWrite.All"
)

# Get Graph Service Principal
$graphSp = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'"

# Assign Permissions
$resourceAccess = @()

foreach ($perm in $permissions) {
    $role = $graphSp.AppRoles | Where-Object { $_.Value -eq $perm }

    if ($null -ne $role) {
        $resourceAccess += @{
            Id = $role.Id
            Type = "Role"
        }
    }
    else {
        Write-Warning "Permission not found: $perm"
    }
}

# Update App with permissions
Update-MgApplication -ApplicationId $app.Id -RequiredResourceAccess @(
    @{
        ResourceAppId = $graphAppId
        ResourceAccess = $resourceAccess
    }
)

# ================================
# Create Client Secret
# ================================
$secret = Add-MgApplicationPassword -ApplicationId $app.Id -PasswordCredential @{
    DisplayName = "ClientSecret"
    EndDateTime = (Get-Date).AddYears(1)
}

# ================================
# Output
# ================================
Write-Host ""
Write-Host "====================================="
Write-Host "App Registration Created!"
Write-Host "-------------------------------------"
Write-Host "Tenant ID: $tenantId"
Write-Host "Client ID: $($app.AppId)"
Write-Host "Client Secret: $($secret.SecretText)"
Write-Host "====================================="
Write-Host ""

Write-Host "IMPORTANT: Grant admin consent in Entra ID portal."
