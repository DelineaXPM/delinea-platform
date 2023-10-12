# Input parameters
$adminServer = $args[0]
$adminPort = '1521'
$adminSid = 'ORCL'
$adminUsername = $args[1]
$adminPassword = $args[2]
$userToChange = $args[3]
$newPassword = $args[4]

# Specify the path of the Oracle Managed Data Access .NET data provider
$oracleDllPath = "C:\Program Files\Thycotic Software Ltd\Distributed Engine\Oracle.ManagedDataAccess.dll"

# Load the DLL file
[Reflection.Assembly]::LoadFile($oracleDllPath) | Out-Null  # Suppress output

# Create a connection to the Oracle database with admin credentials
$adminConnectionString = "User Id=$adminUsername;Password=$adminPassword;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$adminServer)(PORT=$adminPort))(CONNECT_DATA=(SID=$adminSid)))"
$adminConnection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection
$adminConnection.ConnectionString = $adminConnectionString

# Try to open the admin connection
try {
    $adminConnection.Open()
    if ($adminConnection.State -eq 'Open') {
        Write-Output "Connected to Oracle Database on $adminServer as admin user $adminUsername"
    } else {
        throw "Admin Connection Failed"
    }
}
catch {
    throw "Admin Connection Error: $_"
}

# Change the password for the specified user
$changePasswordQuery = "ALTER USER $userToChange IDENTIFIED BY $newPassword"
$changePasswordCommand = $adminConnection.CreateCommand()
$changePasswordCommand.CommandText = $changePasswordQuery

try {
    $result = $changePasswordCommand.ExecuteNonQuery()
    if ($result -eq -1) {
        Write-Output "Password changed successfully for user $($userToChange)"
    }
}
catch {
    throw "Error changing password for user $($userToChange): $_"
}
finally {
    $adminConnection.Close()
}