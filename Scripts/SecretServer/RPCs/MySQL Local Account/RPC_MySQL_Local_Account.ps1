<#
	Created by Cagdas Barak - Delinea
	
    .SYNOPSIS
    Discovery script created to change the password of the specified account on the MYSQL DB on the target machine using MySql.Data.dll.
    .DESCRIPTION
    Finds MySQL Entries in all examples using the MySql.Data.dll library.
    NOTES
    Requires the MySql.Data.dll library to be available.
    Tested with MySql.Data.dll version 8.1.0.
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path with errors.
    A file will be created for each server and overwritten on each run.
#>

# Collect the necessary information for connecting to the MySQL database
$mysqlHost = $args[0]
$adminUser = $args[1]
$adminPassword = $args[2]
$usernameToChange = $args[3]
$newPassword = $args[4]

try {
    # Specify the path of the MySQL .NET data provider
    $mysqlDllPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll"

    # Load the DLL file
    [System.Reflection.Assembly]::LoadFile($mysqlDllPath) | Out-Null  # Suppress output

    # Define the MySQL connection string
    $connectionString = "server=$mysqlHost;user=$adminUser;password=$adminPassword;database=mysql"

    # Create a MySQL connection
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    # Create the password change query
    $changePasswordQuery = "SET PASSWORD FOR '$usernameToChange'@'%' = '$newPassword';"

    # Execute the query
    $command = $connection.CreateCommand()
    $command.CommandText = $changePasswordQuery
    $result = $command.ExecuteNonQuery()

    if ($result -eq 0) {
        Write-Output "[$(Get-Date -Format yyyyMMdd)] Password for user '$usernameToChange' successfully changed."

        # Refresh PRIVILEGES
        $flushCommand = "FLUSH PRIVILEGES;"
        $flushCommandResult = $command.ExecuteNonQuery()

        if ($flushCommandResult -eq 0) {
            Write-Output "[$(Get-Date -Format yyyyMMdd)] PRIVILEGES refreshed successfully."
        } else {
            Write-Output "[$(Get-Date -Format yyyyMMdd)] Failed to refresh PRIVILEGES."
        }
    } else {
        Write-Output "[$(Get-Date -Format yyyyMMdd)] Error changing password."
    }

    # Close the MySQL connection
    $connection.Close()
} catch {
    Write-Output "[$(Get-Date -Format yyyyMMdd)] An error occurred: $($_.Exception.Message)"
}