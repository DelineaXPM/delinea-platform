<#
	Created by Cagdas Barak - Delinea

    .SYNOPSIS
    Discovery scanner script that lists Oracle Database users for Secret Server extensible discovery.

    .DESCRIPTION
    Runs on the Distributed Engine (or web node) and uses the Oracle.ManagedDataAccess.dll that ships
    with it, so nothing is installed on the database server. It returns one object per open,
    non Oracle-maintained account in DBA_USERS.

    Scanner arguments:
        $target $[1]$Username $[1]$Password [port] [service name]

    - port defaults to 1521.
    - If a service name is given (for example FREEPDB1 or ORCLPDB1), the script connects with
      SERVICE_NAME, which is what pluggable databases need. If it is omitted, the script connects
      with SID=ORCL, as the original version did.

    Each result has Machine, Resource, Username, Database and Port. Resource and Username map to the
    Account (Basic) parent fields. Database and Port are optional: add them to the scan template and
    map them to the Oracle Account (Template Ver 2) password changer so imported secrets are complete.

    .NOTES
    Current engines ship ODP.NET 23 (Oracle.ManagedDataAccess 4.122.23.x), which depends on
    System.Text.Json 8 and other assemblies in the engine folder. Assembly LoadFile does not look in
    that folder, so OracleConnection fails with "The type initializer for
    'OracleInternal.Common.ProviderConfig' threw an exception". The AssemblyResolve handler below
    loads those dependencies from the engine folder.

    The discovery account needs CREATE SESSION and SELECT on DBA_USERS (SELECT_CATALOG_ROLE is enough).
#>

# Input parameters
$server      = $args[0]
$username    = $args[1]
$password    = $args[2]
$port        = if ($args.Count -gt 3 -and $args[3]) { $args[3] } else { '1521' }
$serviceName = if ($args.Count -gt 4 -and $args[4]) { $args[4] } else { $null }
$sid         = 'ORCL'

# Locate the Oracle Managed Data Access provider that ships with Secret Server
$oracleDllPath = @(
    "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Oracle.ManagedDataAccess.dll",
    "${env:ProgramFiles(x86)}\Thycotic Software Ltd\Distributed Engine\Oracle.ManagedDataAccess.dll",
    "C:\Oracle\Oracle.ManagedDataAccess.dll"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $oracleDllPath) { throw "Oracle.ManagedDataAccess.dll not found on this engine" }

# Resolve ODP.NET dependencies (System.Text.Json etc.) from the same folder
$script:OdpFolder = Split-Path $oracleDllPath
[AppDomain]::CurrentDomain.add_AssemblyResolve({
    param($sender, $e)
    $candidate = Join-Path $script:OdpFolder ((New-Object Reflection.AssemblyName $e.Name).Name + '.dll')
    if (Test-Path $candidate) { return [Reflection.Assembly]::LoadFrom($candidate) }
    return $null
})
[Reflection.Assembly]::LoadFrom($oracleDllPath) | Out-Null

$connectData = if ($serviceName) { "SERVICE_NAME=$serviceName" } else { "SID=$sid" }
$dataSource  = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$server)(PORT=$port))(CONNECT_DATA=($connectData)))"
$database    = if ($serviceName) { $serviceName } else { $sid }

try {
    $connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection -ErrorAction Stop
    $connection.ConnectionString = "User Id=$username;Password=$password;Data Source=$dataSource"
    $connection.Open()

    # Open accounts that Oracle does not maintain (application, service and admin users, including C## common users)
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT username FROM dba_users WHERE oracle_maintained = 'N' AND account_status = 'OPEN' ORDER BY username"
    $reader = $command.ExecuteReader()
    $foundOracleUsers = while ($reader.Read()) {
        [pscustomobject]@{
            Machine  = $server
            Resource = $server
            Username = $reader['USERNAME'].ToString().Trim()
            Database = $database
            Port     = $port
        }
    }
    $reader.Close()
}
catch {
    throw "Oracle discovery failed for ${server}:${port} ($connectData): $($_.Exception.Message)"
}
finally {
    if ($connection) { $connection.Close() }
}

# Return only the account objects; anything else written to the output stream becomes a scan result
$foundOracleUsers
