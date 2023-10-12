<#
	Created by Cagdas Barak - Delinea
	
    .SYNOPSIS
    PowerShell script created to establish a heartbeat for Oracle Database accounts.
    .DESCRIPTION
    The script uses Oracle.ManagedDataAccess.dll, which should be located in the C:\Oracle\ directory.
    NOTES
    The logPath variable is used for troubleshooting, and an error file is written to this path when necessary.
    A file will be created for each server and overwritten on each run.
#>

# Input parameters
$server = $args[0]
$port = '1521'
$sid = 'ORCL'
$username = $args[1]
$password = $args[2]

# Specify the path of the Oracle Managed Data Access .NET data provider
$oracleDllPath = "C:\Oracle\Oracle.ManagedDataAccess.dll"

# Load the DLL file
[Reflection.Assembly]::LoadFile($oracleDllPath) | Out-Null  # Suppress output

# Create a connection to the Oracle database
$connectionString = "User Id=$username;Password=$password;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$server)(PORT=$port))(CONNECT_DATA=(SID=$sid)))"
$connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection
$connection.ConnectionString = $connectionString

# Try to open the connection
try {
    $connection.Open()
    if ($connection.State -eq 'Open') {
        Write-Output "Successful"
    } else {
        throw "Connection Failed"
    }
}
catch {
    throw "Connection Error: $_"
}
finally {
    $connection.Close()
}