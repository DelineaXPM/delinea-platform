# DISCLAIMER: This script is provided as-is without any warranties.

# Please thoroughly review the code and test it in a controlled

# environment before deploying it in a production setting.

# Use it at your own risk.

# Created: 2023-08-03

# Description: PowerShell script to install and register the Delinea Connector

# Task 1: Install Delinea Connector package

$packagePath = "Delinea-Connector-Installer.exe"

Write-Host "Task 1 starting: Installing the Delinea Connector package"

# Check if the package file exists

if (Test-Path $packagePath) {

# Install the package using Start-Process

Start-Process -FilePath $packagePath -ArgumentList "/quiet" -Wait

Write-Host "Installation completed successfully."

} else {

Write-Host "Package file not found at $packagePath. Please provide the correct path and try again."

}

# Task 2: Register the connector using URL and registration code

$registrationExec = "C:\Program Files\Delinea\Delinea Connector\DelineaRegisterProxy.exe"

$registrationURL = "https://add-your-tenant-name.delinea.app/identity"

$registrationCode = "ABC1234-ABC1234-ABC1234-ABC1234-1234567890"

Write-Host "Task 2 starting: Registering the Delinea Connector"

#

& $registrationExec "url=$registrationURL" "regcode=$registrationCode"

Write-Host "Connector registration completed."

# Task 3: Restart the service

$serviceName = "delineaproxy"

Write-Host "Task 3 starting: Restarting the Delinea Connector service"

# Restart the service using Restart-Service cmdlet

Restart-Service -Name $serviceName

Write-Host "Service '$serviceName' restarted successfully."