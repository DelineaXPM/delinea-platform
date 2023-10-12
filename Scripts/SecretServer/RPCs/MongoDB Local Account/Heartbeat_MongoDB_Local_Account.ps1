<#
    Created by Cagdas Barak - Delinea
    
.SYNOPSIS
   Created for the MongoDB account to do Heartbeat.
.DESCRIPTION
    Created for the MongoDB account to perform a Heartbeat.
NOTES
   The MongoSH file must be under the following path.
   "C:\MongoDB\bin\mongosh.exe"
   -
#>

# Get MongoDB connection information
$mongoHost = $args[0]
$mongoPort = '27017'
$mongoDb = 'admin'
$username = $args[1]
$password = $args[2]

$mongoExePath = "C:\MongoDB\bin\mongosh.exe"

$output = & $mongoExePath --host $mongoHost --port $mongoPort -u $userName -p "$password" --eval "db.runCommand({ping: 1})" 2>&1

if ($output -imatch "authentication failed") {
    throw "Connection Failed"
}