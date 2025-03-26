# IIS Manager
## Background
MMC applications cannot be directly launched as [they require elevation](https://docs.delinea.com/online-help/secret-server/secret-launchers/custom-launchers/custom-launcher-errors/index.htm). 
## Implementation
1) Create a process launcher
2) Select the **Run Process As Secret Credentials** and **Load User Profile** options
3) Enter Process Name `powershell.exe`
4) Enter Process Arguments	`-noprofile -executionpolicy bypass -windowstyle hidden -command cmd.exe -ArgumentList "/c iis.msc"`
