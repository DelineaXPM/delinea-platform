<#
	Created by Cagdas Barak - Delinea
	
    .SYNOPSIS
     Discovery script for finding MySQL Logins on the target machine.
    .DESCRIPTION
    C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0 path must have MySQL.Data.dll file.
    NOTES
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path with errors.
    A file will be created for each server and overwritten on each run.
#>

$server = $args[0]
$port = '3306'
$username = $args[1]
$password = $args[2]

$FoundMySQLUsers = @()

try {
    # Specify the path of the MySQL .NET data provider
    $mysqlDllPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll"

    # Load the DLL file
    [System.Reflection.Assembly]::LoadFile($mysqlDllPath) | Out-Null  # Suppress output

    # Create a connection to the MySQL database
    $connectionString = "Server=$server;Port=$port;Uid=$username;Pwd=$password;"
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    # Create a query
    $query = "SELECT User FROM mysql.user WHERE User != 'mysql.sys' AND User != 'mysql.session' AND User != 'mysql.infoschema';"
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    # Run the query and read the results
    $reader = $command.ExecuteReader()

    while ($reader.Read()) {
        $object = New-Object –TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name Machine -Value $mysqlHost
        $object | Add-Member -MemberType NoteProperty -Name Username -Value $reader["User"]
        $FoundMySQLUsers += $object
    }

    $reader.Close()
    $connection.Close()
} catch {
    throw "Hata: $($_.Exception.Message)"
}

$FoundMySQLUsers