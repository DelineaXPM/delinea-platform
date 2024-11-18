# Introduction

This documents provides the details for configuring a dependency changer to force a windows computer to restart.

## Windows Computer Restart

This dependency will attempt to gracefully restart the server. In most cases the standard script will provide the required functionality. In some environments [credssp](https://docs.delinea.com/secrets/current/authentication/configuring-credssp-for-winrm-with-powershell/index.md) will need to be leveraged and preconfigured.

## Create Script

1. Navigate to **Admin | Scripts**
2. Enter name: **Windows Computer Restart**
3. Description: **Script for forcing a computer restart**
4. Category: **Dependency**
5. Script: **Copy and Paste** one of the scripts [restart-windows.ps1](restart-windows.ps1) / [restart-windows-nocredssp.ps1](restart-windows-nocredssp.ps1)
6. Click **OK**

## Create Dependency

1. Navigate to your desired secret
2. Navigate to **Dependencies** tab
3. Create a **New Dependency** (_create a dependency group if one does not currently exist_)
4. Click the drop down for **Type**
5. Select the **Windows Computer Restart** under the **Run PowerShell Script** section
6. Provide a **Dependency Name**
7. Select a **Run As** secret if required according to your Secret Server configuration
8. Enter **5** for **Wait(s)**
9. For Arguments enter the appropriate arguments for your script

| Script | Arguments |
| ------------- | ------------- |
| [restart-windows.ps1](restart-windows.ps1) |  `$MACHINE` |
| [restart-windows-nocredssp.ps1](restart-windows-nocredssp.ps1) | ` $[1]$USERNAME $[1]$DOMAIN $[1]$PASSWORD $MACHINE` |

11. Click **Save**
