v# Installation Steps of the PoSH Utils Delinea Helper Module

1. Open PowerShell with administrative privileges as this will be installed on the root drive in Windows under the Program Files folder.

2. Navigate to the root directory of your PowerShell module project.

3. Use the `Copy-Item` cmdlet to copy the module folder to the desired directory. The file: `.\Delinea.PoSH.Helpers\Utils.psm1` Needs to be in the directory: `$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\`

   ```powershell
   Copy-Item -Path ".\Delinea.PoSH.Helpers\Utils.psm1" -Destination "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\" -Recurse -Force

## If the Error Occurs:

```powershell
Copy-Item : Could not find a part of the path 'C:\Program Files\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\'
```

## The Issue is Caused Because the Path Does Not Exist, Run This Command in an Admin Powershell Terminal:

```powershell
if (-not (Test-Path -Path "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers" -PathType Container)) {
    New-Item -Path "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers" -ItemType Directory
}
```

## The Output Will Show successful:

```powershell
    Directory: C:\Program Files\Thycotic Software Ltd\Distributed Engine


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         1/30/2024   2:59 PM                Delinea.PoSH.Helpers
```

## Then Run the Command Again and it Will Copy Over. 

- Check it by Running:

```powershell
Get-Content "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\"
```