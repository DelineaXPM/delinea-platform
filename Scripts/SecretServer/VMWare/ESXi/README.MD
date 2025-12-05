# ESXi Pre-Requisites & Diagnostics Utility

A PowerShell utility for preparing a Windows host for VMware PowerCLI usage in Delinea Secret Server environments and performing ESXi Heartbeat and Discovery diagnostic tests.

## 📌 Overview

This script provides three primary capabilities:

- Install and configure VMware PowerCLI
- Copy required VMware Binding DLLs needed for some Secret Server VMware RPCs
- Run ESXi connectivity diagnostics (Heartbeat and Discovery)

All operations are driven through a simple menu system.

## 🚀 Features

### 1. PowerCLI Installation & Environment Prep

The script:

- Installs NuGet provider
- Installs VMware.PowerCLI (only if missing)
- Locates module directories:
  - VMware.VimAutomation.Common
  - VMware.Vim
- Detects .NET subfolders (net472 / net45)
- Copies required assemblies:
  - VMware.Binding.Wcf.dll
  - VMware.Binding.WsTrust.dll
- Adds module path to system PATH
- Optionally restarts the Thycotic Distributed Engine Service

This fixes missing-binding errors commonly seen in Secret Server VMware RPCs.

### 2. ESXi Heartbeat Test

Simulates a Secret Server Heartbeat operation:

- Attempts connection using Unset certificate mode (SS default)
- Falls back to Ignore if the first attempt fails
- Displays success/failure clearly
- Cleanly disconnects from host

Useful for validating:

- Credentials
- Host reachability
- Certificate behavior
- PowerCLI compatibility

### 3. ESXi Discovery Test

Simulates Secret Server account discovery:

- Connects with Unset → Ignore fallback
- Runs Get-VMHostAccount
- Displays discovered accounts in a formatted table
- Disconnects automatically

## 📋 Menu Options

When executed, the script displays:

1. Install PowerCLI and copy required files for Secret Server
2. Test a VMware ESXi Heartbeat
3. Test scanning a VMware host for accounts (Discovery)

## 🔧 Helper Functions

| Function | Purpose |
|----------|---------|
| `Initialize-NuGetProvider` | Ensures NuGet package provider is installed. |
| `Get-ModuleFolderPath` | Returns the filesystem path of a PowerShell module. |
| `Get-NetFolderPath` | Locates .NET runtime folders inside modules. |
| `Restart-ThycoticService` | Stops and restarts the Distributed Engine service. |
| `Add-ToSystemPath` | Safely appends a directory to the system PATH. |
| `Install-PowerCLIAndCopyFiles` | Complete PowerCLI + DLL copy workflow. |
| `Test-VMWareHeartbeat` | Performs ESXi heartbeat-style connection test. |
| `Test-VMWareDiscovery` | Connects to ESXi and enumerates local accounts. |

## 🧩 Requirements

- Windows host running (optional) Secret Server Distributed Engine
- PowerShell 5.1+
- Administrative rights (for PATH updates)
- Internet access for module installation
- ESXi host reachable over TCP 443

## ▶️ Usage

Run the script:

```powershell
.\Esxi-PreReqs.ps1
```

### Option 1 – Install PowerCLI + Copy DLLs

Follow menu prompts.

### Option 2 – Test Heartbeat

- Enter ESXi hostname or IP
- Enter credentials

### Option 3 – Test Discovery

- Enter ESXi hostname or IP
- Enter credentials

## ⚠️ Notes & Best Practices

- PowerCLI certificate mode changes are session-only, matching SS RPC behavior.
- DLL copy logic is required due to VMware module packaging differences.
- A restart of Thycotic.DistributedEngine.Service is recommended after installation.
- Test in a lab before using in production environments.
