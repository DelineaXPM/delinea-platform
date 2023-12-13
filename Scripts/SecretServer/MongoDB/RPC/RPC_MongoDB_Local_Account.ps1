<#
    Created by Cagdas Barak - Delinea
    
.SYNOPSIS
    Created for MongoDB account to make Password Change using an Authorised account.
.DESCRIPTION
    Created for MongoDB account to make Password Change using an Authorised account.
NOTES
    The MongoSH file must be under the following path.
    "C:\MongoDB\bin\mongosh.exe"
    -
#>

# Get MongoDB connection information
$mongoHost = $args[0]
$mongoPort = '27017'
$mongoAdminDb = 'admin'
$userNameToChange = $args[1]
$newPassword = $args[2]
$adminUserName = $args[3]
$adminPassword = $args[4]

$mongoExePath = "C:\MongoDB\bin\mongosh.exe"

try {
    # Create the password change command
    $query = "db.changeUserPassword('$userNameToChange', '$newPassword')"

    # Execute the password change command
    $connectionString = "mongodb://${adminUserName}:${adminPassword}@${mongoHost}:${mongoPort}/${mongoAdminDb}"
    $changePasswordOutput = & $mongoExePath $connectionString --authenticationDatabase admin --eval $query

    # Check the output to determine if it was successful or failed
    if ($changePasswordOutput -match "Authentication failed") {
        Write-Host "Failed"
    } else {
        Write-Host "Successful"
    }
}
catch {
    Write-Host "Failed"
}