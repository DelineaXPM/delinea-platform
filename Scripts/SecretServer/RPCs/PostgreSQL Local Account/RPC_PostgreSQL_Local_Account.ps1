<#
    Created by Cagdas Barak - Delinea
    
    .SYNOPSIS
    PowerShell script created for PostgreSQL local users to do Heartbeat.
    .DESCRIPTION
    Make sure that npgsql.dll exists in the specified path.
"C:\Program Files (x86)\PostgreSQL\Npgsql\bin\net451\System.Threading.Tasks.Extensions.dll"
    NOTES
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path on errors.
    A file will be created for each server and overwritten on each run.
#>

# Initialize variables to store database connection parameters
$dbHost = $null
$dbPort = $null
$dbName = $null
$userName = $null
$adminUserName = $null
$adminPassword = $null

# PostgreSQL connection information
$dbHost = $args[0]
$dbPort = '5432'
$dbName = 'postgres'
$userName = $args[1]
$newPassword = $args[2]
$adminUserName = $args[3]
$adminPassword = $args[4]

# Npgsql assembly path
$npgsqlPath = "C:\Program Files (x86)\PostgreSQL\Npgsql\bin\net451\Npgsql.dll"

# Load the Npgsql assembly
try {
    Add-Type -Path $npgsqlPath
}
catch {
    throw "Npgsql assembly could not be loaded. Make sure the path is correct."
}

# PostgreSQL connection string
$connectionString = "Host=$dbHost;Port=$port;Database=$dbName;Username=$adminUserName;Password=$adminPassword;"

# Create a new Npgsql connection
$connection = New-Object Npgsql.NpgsqlConnection
$connection.ConnectionString = $connectionString

try {
    # Open the connection
    $connection.Open()

    # Create a command to change PostgreSQL user's password
    $query = "ALTER USER $userName WITH PASSWORD '$newPassword'"
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    # Execute the command and check the result
    $command.ExecuteNonQuery() | Out-Null

    Write-Host "Success: Password changed successfully."
}
catch {
    throw $_
}
finally {
    # Close the connection
    $connection.Close()
}