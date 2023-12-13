<#
	Created by Cagdas Barak - Delinea
	
    .SYNOPSIS
    PowerShell script created to list Oracle Database users.
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
$oracleDllPath = "C:\Program Files\Thycotic Software Ltd\Distributed Engine\Oracle.ManagedDataAccess.dll"

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
        Write-Output "Connected to Oracle Database on $server"
    } else {
        throw "Connection Failed"
    }
}
catch {
    throw "Connection Error: $_"
}

# Query to list Oracle users with usernames starting with "C##"
$query = "SELECT username FROM dba_users WHERE username LIKE 'C##%'"
$command = $connection.CreateCommand()
$command.CommandText = $query

# Execute the query and store usernames in an array of custom objects
$FoundOracleUsers = @()
$reader = $command.ExecuteReader()
while ($reader.Read()) {
    $object = New-Object PSObject -Property @{
        Machine = $server
        Username = $reader["USERNAME"].Trim()
    }
    $FoundOracleUsers += $object
}

# Close the connection
$reader.Close()
$connection.Close()

# Output the custom objects
$FoundOracleUsers