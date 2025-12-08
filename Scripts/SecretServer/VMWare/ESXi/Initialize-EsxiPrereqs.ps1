#region Helper Functions

function Initialize-NuGetProvider {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "NuGet provider is not installed. Installing..."
        Install-PackageProvider -Name NuGet -MinimumVersion "2.8.5.201" -Force -Scope CurrentUser
    }
}

function Get-ModuleFolderPath {
    param (
        [Parameter(Mandatory)]
        [string]$ModuleName
    )
    $mod = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    if ($mod) { return $mod.ModuleBase } else { return $null }
}

function Get-NetFolderPath {
    param (
        [Parameter(Mandatory)]
        [string]$ModuleFolder
    )
    foreach ($net in @("net472", "net45")) {
        $path = Join-Path -Path $ModuleFolder -ChildPath $net
        if (Test-Path $path) { return $path }
    }
    return $null
}

function Restart-ThycoticService {
    param(
        [string]$ServiceName = "Thycotic.DistributedEngine.Service",
        [int]$WaitIntervalSeconds = 15,
        [int]$MaxWaitSeconds = 60
    )
    Write-Host "Restarting $ServiceName..."
    $null = Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Write-Warning ("Service '{0}' is stopping. Waiting up to {1} seconds..." -f $ServiceName, $MaxWaitSeconds)
    $elapsed = 0
    while ((Get-Service -Name $ServiceName).Status -ne "Stopped" -and ($elapsed -lt $MaxWaitSeconds)) {
        Start-Sleep -Seconds $WaitIntervalSeconds
        $elapsed += $WaitIntervalSeconds
    }
    try {
        Start-Service -Name $ServiceName
        Write-Host "$ServiceName restarted successfully."
    }
    catch {
        Write-Error ("Failed to restart {0}: {1}" -f $ServiceName, $_.Exception.Message)
    }
}

function Add-ToSystemPath {
    param(
        [Parameter(Mandatory)]
        [string]$PathToAdd
    )
    try {
        $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$PathToAdd*") {
            $newPath = $currentPath + ";" + $PathToAdd
            [System.Environment]::SetEnvironmentVariable("PATH", $newPath, [System.EnvironmentVariableTarget]::Machine)
            Write-Host ("Added '{0}' to the system PATH variable. A shell restart may be required." -f $PathToAdd)
        }
        else {
            Write-Host ("'{0}' is already in the system PATH." -f $PathToAdd)
        }
    }
    catch {
        Write-Warning ("Failed to update system PATH: {0}" -f $_.Exception.Message)
    }
}

function Install-PowerCLIAndCopyFiles {
    Write-Host "=== Installing PowerCLI and copying required files for Secret Server ===" -ForegroundColor Cyan

    Initialize-NuGetProvider
    if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
        Write-Host "PowerCLI not found. Installing VMware.PowerCLI..."
        try {
            Install-Module -Name VMware.PowerCLI -Force -Scope CurrentUser -AllowClobber
        }
        catch {
            Write-Error ("Failed to install VMware.PowerCLI: {0}" -f $_.Exception.Message)
            return
        }
    }
    else {
        Write-Host "PowerCLI is already installed."
    }
    $commonModuleBase = Get-ModuleFolderPath -ModuleName "VMware.VimAutomation.Common"
    $vimModuleBase    = Get-ModuleFolderPath -ModuleName "VMware.Vim"
    if (-not $commonModuleBase) {
        Write-Error "Could not locate the VMware.VimAutomation.Common module folder."
        return
    }
    if (-not $vimModuleBase) {
        Write-Error "Could not locate the VMware.Vim module folder."
        return
    }
    $sourcePath = Get-NetFolderPath -ModuleFolder $commonModuleBase
    $destinationPath = Get-NetFolderPath -ModuleFolder $vimModuleBase
    if (-not $sourcePath) {
        Write-Error ("Source directory (net472/net45) not found under {0}." -f $commonModuleBase)
        return
    }
    if (-not $destinationPath) {
        Write-Error ("Destination directory (net472/net45) not found under {0}." -f $vimModuleBase)
        return
    }
    $files = @("VMware.Binding.Wcf.dll", "VMware.Binding.WsTrust.dll")
    foreach ($file in $files) {
        $sourceFile = Join-Path -Path $sourcePath -ChildPath $file
        $destFile = Join-Path -Path $destinationPath -ChildPath $file
        if (Test-Path $sourceFile) {
            Write-Host ("Copying {0} from {1} to {2}..." -f $file, $sourcePath, $destinationPath)
            try {
                Copy-Item -Path $sourceFile -Destination $destFile -Force
                Write-Host ("Copied {0} successfully." -f $file)
            }
            catch {
                Write-Warning ("Failed to copy {0}: {1}" -f $file, $_.Exception.Message)
            }
        }
        else {
            Write-Warning ("File {0} was not found in {1}." -f $file, $sourcePath)
        }
    }
    Write-Host "Updating the system PATH variable..."
    Add-ToSystemPath -PathToAdd $destinationPath
    $restart = Read-Host "Do you want to restart Thycotic.DistributedEngine.Service now? (Y/N)"
    if ($restart -match "^[Yy]") {
        Restart-ThycoticService
    }
    else {
        Write-Host "Reminder: Restart the Thycotic.DistributedEngine.Service later for changes to take effect."
    }
}

#endregion Helper Functions

function Test-VMWareHeartbeat {
    param (
        [string]$esxiHost,
        [PSCredential]$cred
    )
    Write-Host "=== Testing VMware ESXi Heartbeat ===" -ForegroundColor Cyan
    Write-Host ("Attempting to connect to {0} with default cert policy (Unset)..." -f $esxiHost)
    Write-Host "This could take up to 5 minutes (connection will time out after 5 mins)"

    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Unset -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope Session -DefaultVIServerMode Single -Confirm:$false | Out-Null

    try {
        Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction Stop | Out-Null
        Write-Host "Connection succeeded with default cert policy." -ForegroundColor Green
        Disconnect-VIServer -Server $esxiHost -Confirm:$false | Out-Null
        return
    }
    catch {
        Write-Warning "Default connection failed due to certificate issues."
    }

    Write-Host "Setting session cert policy to Ignore (session only) and retrying..." -ForegroundColor Yellow
    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
    Set-PowerCLIConfiguration -Scope Session -DefaultVIServerMode Single -Confirm:$false | Out-Null

    try {
        Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction Stop | Out-Null
        Write-Host "Connection succeeded with certificates ignored (session only)." -ForegroundColor Green
    }
    catch {
        Write-Error "Heartbeat failed even with certificates ignored: $_"
    }
    finally {
        Disconnect-VIServer -Server $esxiHost -Confirm:$false | Out-Null
    }
}

function Test-VMWareDiscovery {
    param (
        [string]$esxiHost,
        [PSCredential]$cred
    )
    Write-Host "=== Testing VMware Host Account Discovery ===" -ForegroundColor Cyan
    Write-Host "Attempting to connect to $esxiHost with default cert policy (Unset)..."
    Write-Host "This could take up to 5 minutes (connection will time out after 5 mins)"

    # Phase 1: default Unset
    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Unset -Confirm:$false | Out-Null
    try {
        $connection = Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction Stop
    }
    catch {
        Write-Warning "Default connection failed due to certificate issues."
        Write-Host "Setting session cert policy to Ignore (session only) and retrying..." -ForegroundColor Yellow
        Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
        $connection = Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction Stop
    }

    Write-Host "Connection successful. Scanning for user accounts on $esxiHost..."
    # Retrieve all accounts via the connected server
    $accounts = Get-VMHostAccount -Server $connection -ErrorAction Stop
    if ($accounts) {
        $accounts | Format-Table -AutoSize
    }
    else {
        Write-Host "No user accounts were found." -ForegroundColor Yellow
    }

    Disconnect-VIServer -Server $connection -Confirm:$false | Out-Null
}

#region Main Script Prompt

Write-Host ""
Write-Host "Select an option:" -ForegroundColor Green
Write-Host "1. Install PowerCLI and copy required files for Secret Server"
Write-Host "2. Test a VMware ESXi Heartbeat"
Write-Host "3. Test scanning a VMware host for accounts (Discovery)"
$choice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($choice) {
    "1" { Install-PowerCLIAndCopyFiles }
    "2" {
        $esxiHost = Read-Host "Enter the ESXi host name or IP for Heartbeat test"
        $cred = Get-Credential -Message "Enter credentials for connecting to the ESXi host"
        Test-VMWareHeartbeat -esxiHost $esxiHost -cred $cred
    }
    "3" {
        $esxiHost = Read-Host "Enter the ESXi host name or IP for Discovery scan"
        $cred = Get-Credential -Message "Enter credentials for connecting to the ESXi host"
        Test-VMWareDiscovery -esxiHost $esxiHost -cred $cred
    }
    Default { Write-Host "Invalid selection. Exiting." }
}

#endregion Main Script Prompt
