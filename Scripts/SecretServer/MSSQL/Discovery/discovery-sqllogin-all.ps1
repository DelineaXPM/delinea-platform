<#
    .SYNOPSIS
    Discovery script for finding all SQL Logins on a the target machine
    .EXAMPLE
    Expected arguments: $TARGET $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD
    .EXAMPLE
    Expected arguments: $TARGET $[1]$USERNAME $[1]$PASSWORD
    Use lines 32/33 or 36/37 based on account type
    .NOTES
    Depends upon dbatools module being installed on the Secret Server Web Node or the Distributed Engine
    Reference: https://www.powershellgallery.com/packages/dbatools/
    Tested with version 1.0.107
    logPath variable below used for troubleshooting if required, file is written to this path with errors.
    A file for each server will be created, and overwritten on each run.
#>
$logPath = 'C:\scripts'

$TargetServer = $args[0]

$logFile = "$logPath\$($TargetServer)_findsqllogins.txt"
Write-Output "[$(Get-Date -Format yyyyMMdd)] Processing Targeting machine: $TargetServer" | Out-File $logFile -Force

<# Based on credential type of argument #>
# Windows Domain with domain name
$Username = "$($args[1])\$($args[2])"
$Password = $args[3]

# Windows Domain without domain name
# $Username = $args[1]
# $Password = $args[2]

# Using SQL Login Account privileged account
# $Username = $params[1]
# $Password = $params[2]

if ( $Username -and $Password ) {
    $passwd = $Password | ConvertTo-SecureString -AsPlainText -Force
    $sqlCred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$passwd
    Write-Output "[$(Get-Date -Format yyyyMMdd)] Using Privileged Account: $($sqlCred.Username)" | Out-File $logFile -Force
}

$ProgressPreference = 'SilentlyContinue'
if (-not (Get-InstalledModule dbatools)) {
    Write-Output "[$(Get-Date -Format yyyyMMdd)] dbatools module not found" | Out-File $logFile -Force
    throw "The module dbatools is required for this script. Please run 'Install-Module dbatools' in an elevated session on your Distributed Engine and/or Web Node."
} else {
    Import-Module dbatools -Force
    <# disable dbatools commands attempting to resolve the target name #>
    $null = Set-DbatoolsConfig -FullName commands.resolve-dbanetworkname.bypass -Value $true
}

<# Find all the SQL Server instances #>
try {
    <# Depends upong Discovery Account #>
    $p = @{
        ComputerName    = $TargetServer
        ScanType        = 'SqlService'
        EnableException = $true
    }
    $sqlEngines = Find-DbaInstance @p
    Write-Output "[$(Get-Date -Format yyyyMMdd)] SQL Instances found: $($sqlEngines.SqlInstance -join ',')" | Out-File $logFile -Force
} catch {
    if (Test-Path $logPath) {
        Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue finding SQL Instances on $TargetServer - $($_.Exception.Message)" | Out-File $logFile -Force
    } else {
        Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue finding SQL Instances on $TargetServer - $($_.Exception.Message)"
    }
    throw "Issue finding SQL instances on $TargetServer - $_"
}

if ($sqlEngines) {
    foreach ($engine in $sqlEngines) {
        $sqlInstanceValue = $engine.SqlInstance
        try {
            <#
                Connect to each instance found
            #>
            $p = @{
                SqlInstance   = $sqlInstanceValue
                SqlCredential = $sqlCred
                ErrorAction   = 'Stop'
            }
            try {
                $cn = Connect-DbaInstance @p
                Write-Output "[$(Get-Date -Format yyyyMMdd)] Connected to SQL Server Instance: $sqlInstanceValue" | Out-File $logFile -Force
            } catch {
                if (Test-Path $logPath) {
                    Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue connecting to $sqlInstanceValue - $($_.Exception.Message)" | Out-File $logFile -Force
                } else {
                    Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue connecting to $sqlInstanceValue - $($_.Exception.Message)"
                }
                continue
            }

            <#
                Find the logins on the instance
            #>
            $p = @{
                SqlInstance     = $cn
                Type            = 'SQL'
                ExcludeFilter   = '##*'
                EnableException = $true
            }
            $logins = Get-DbaLogin @p
            Write-Output "[$(Get-Date -Format yyyyMMdd)] SQL Server Logins count: $($logins.Count)" | Out-File $logFile -Force
        } catch {
            if (Test-Path $logPath) {
                if (Test-Path $logFile) { $append = $true }
                Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue connecting to $sqlInstanceValue - $($_.Exception.Message)" | Out-File $logFile -Append:$append
            } else {
                Write-Output "[$(Get-Date -Format yyyyMMdd)] Issue connecting to $sqlInstanceValue - $($_.Exception.Message)"
            }
            continue
        }

        <# Output object for Discovery #>
        foreach ($login in $logins) {
            Write-Output "[$(Get-Date -Format yyyyMMdd)] SQL Server Login found: $login" | Out-File $logFile -Force
            [PSCustomObject]@{
                Machine  = $login.Parent.Name
                Username = $login.Name
            }
        }
    }
}