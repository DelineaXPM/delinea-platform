<#
    Created by Cagdas Barak - Delinea
    
    .SYNOPSIS
    PowerShell script created to make PostgreSQL connections.
    .DESCRIPTION
    Make sure the Npgsql.dll file is available in the specified path.
    NOTES
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path with errors.
    A file will be created for each server and overwritten on each run.
#>

# PostgreSQL connection information
$server = $args[0]
$port = '5432'
$database = 'postgres'
$username = $args[1]
$password = $args[2]

Add-Type -Path "C:\Program Files (x86)\PostgreSQL\Npgsql\bin\net451\System.Threading.Tasks.Extensions.dll"


# Specify the path of the Npgsql .NET data provider
$npgsqlDllPath = "C:\Program Files (x86)\PostgreSQL\Npgsql\bin\net451\Npgsql.dll"

# Load the DLL file
[System.Reflection.Assembly]::LoadFile($npgsqlDllPath) | Out-Null  # Suppress output

# Construct the PostgreSQL connection string
$connectionString = "Host=$server;Port=$port;Database=$database;Username=$username;Password=$password;"
    
# Create a connection to the PostgreSQL database
$connection = New-Object Npgsql.NpgsqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# If the connection is successful, return "Successful"
if ($connection.State -eq 'Open') {
    return "Successful"
else
    throw "Connection Failed"
}

$connection.Close()