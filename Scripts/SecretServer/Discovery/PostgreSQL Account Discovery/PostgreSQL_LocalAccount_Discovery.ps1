<#
    Created by Cagdas Barak - Delinea

    .SYNOPSIS
    Discovery script for finding PostgreSQL Logins on the target machine.
    .DESCRIPTION
    C:\Program Files (x86)\PostgreSQL\Npgsql\bin\net451\Npgsql.dll path must have Npgsql.dll file.
    NOTES
    The following logPath variable is used for troubleshooting when necessary; a file is written to this path with errors.
    A file will be created for each server and overwritten on each run.
#>

$server = $args[0]
$port = '5432'
$database = 'postgres'
$username = $args[1]
$password = $args[2]

$FoundPostgreSQLUsers = @()

try {
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

    # Sorgu oluştur
    $query = "SELECT usename FROM pg_catalog.pg_user WHERE usename NOT IN ('postgres');"
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    # Sorguyu çalıştır ve sonuçları oku
    $reader = $command.ExecuteReader()

    while ($reader.Read()) {
        $object = New-Object –TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name Machine -Value $server
        $object | Add-Member -MemberType NoteProperty -Name Username -Value $reader["usename"]
        $FoundPostgreSQLUsers += $object
    }

    $reader.Close()
    $connection.Close()
} catch {
    throw "Hata: $($_.Exception.Message)"
}

$FoundPostgreSQLUsers