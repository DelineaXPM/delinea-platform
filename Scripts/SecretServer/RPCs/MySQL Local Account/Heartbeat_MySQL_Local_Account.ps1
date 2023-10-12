<#
	Created by Cagdas Barak - Delinea
	
    .SYNOPSIS
    Powershell script created to make MySQL accounts Heartbeat
    .DESCRIPTION
    C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0 path must have MySQL.Data.dll file.
    NOTES
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path with errors.
    A file will be created for each server and overwritten on each run.
#>

$server = $args[0]
$username = $args[1]
$password = $args[2]

# Specify the path of the MySQL .NET data provider
$mysqlDllPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll"

# Load the DLL file
[System.Reflection.Assembly]::LoadFile($mysqlDllPath) | Out-Null  # Suppress output

# Create a connection to the MySQL database
$connectionString = "Server=$server;Uid=$username;Pwd=$password;"
$connection = New-Object MySql.Data.MySqlClient.MySqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# If the connection is successful, return "Successful"
if ($connection.State -eq 'Open') {
    return "Successful"
else
    throw "Connection Failed"
}

$connection.Close()