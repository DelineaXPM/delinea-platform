# Helper Module for Scripts
Some connectors and integrations will require additional functions provided in this module. If directed please install this module on all distributed engines that will execute the specific code.

## Installation

1. Open PowerShell with administrative privileges as this will be installed on the root drive in Windows under the Program Files folder.
1. Navigate to the root directory of your PowerShell module project.
1. Use the `Copy-Item` cmdlet to copy the module folder to the desired directory. The file: `.\Delinea.PoSH.Helpers\Utils.psm1` Needs to be in the directory: `$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\`

   ```powershell
   Copy-Item -Path ".\Delinea.PoSH.Helpers\Utils.psm1" -Destination "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\" -Recurse -Force

>[!NOTE]
>If an error stating that Copy-Item : Could not find a part of the path ```C:\Program Files\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\```
>The issue is because the path does not exist.
>To resolve run this command in an Admin Powershell Terminal:
```powershell 
if (-not (Test-Path -Path "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers" -PathType Container)) {
    New-Item -Path "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers" -ItemType Directory
}
```


## Functions

### CreatePsCredObj
Used to create secure credential objects

### CheckModuleExist
Verifies that a specific PowerShell module is installed and loaded

### Set-RSASignatureFromPEMString
Calculates Certificate signature

### Get-JWT
Creates a valid JWT


# Disclaimer
The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.

