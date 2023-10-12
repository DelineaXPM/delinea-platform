<#
    Created by Cagdas Barak - Delinea
    
    .SYNOPSIS
    MongoDB local user discovery script for a target machine using mongosh.
    .DESCRIPTION
    Finds MongoDB local users on the target machine using MongoDB Shell (`mongosh` 2.0.0).
    .NOTES
    Requires MongoDB Shell (`mongosh`) version 2.0.0 or later to be installed.
    Tested with MongoDB Shell 2.0.0
    logPath variable below is used for troubleshooting if required; a file is written to this path with errors.
    A file for each server will be created and overwritten on each run.
#>

# Initialize variables to store host name and username
$hostName = $null
$username = $null

# Check if a MongoDB host argument is provided
if ($args.Count -ge 1) {
    $hostName = $args[0]
} else {
    # If no host argument is provided, use the default localhost
    $hostName = "localhost"
}

# Specify MongoDB username and password
if ($args.Count -ge 2) {
    $username = $args[1]
}
if ($args.Count -ge 3) {
    $password = $args[2]
}

# Path to the mongosh executable
$mongoshPath = 'C:\MongoDB\bin\mongosh.exe'

# Check if mongosh executable exists
if (-not (Test-Path $mongoshPath)) {
    Write-Output "[$(Get-Date -Format yyyyMMdd)] The MongoDB Shell (`mongosh.exe`) is required. Please ensure it is installed."
    throw "The MongoDB Shell (`mongosh.exe`) is required. Please ensure it is installed."
}

# Create an empty list to store the MongoDB local users and hostname
$FoundMongoDBUsers = @()
$FoundMongoDBHostname = $hostName

try {
    # Run the command to list MongoDB users
    $query = 'db.adminCommand({ usersInfo: 1 })'
    $connectionString = "mongodb://${username}:${password}@${hostName}/admin"
    $outputLines = & $mongoshPath $connectionString --authenticationDatabase admin --eval $query

    # Split the output into separate lines
    $outputArray = $outputLines -split '\r?\n'

    # Process each line of the output
    foreach ($line in $outputArray) {
        if ($line -match '^(.*): (.*)$') {
            $property = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            if ($property -eq 'user') {
                $object = New-Object -TypeName PSObject -Property @{
                    Hostname = $FoundMongoDBHostname
                    Username = $value -replace "'", "" -replace ",", ""
                }
                $FoundMongoDBUsers += $object
            }
        }
    }

    if ($FoundMongoDBUsers.Count -eq 0) {
        # No MongoDB users found
        Write-Output "[$(Get-Date -Format yyyyMMdd)] No MongoDB users found on host $FoundMongoDBHostname."
    } else {
        # Output usernames and hostname without quotes and commas
        $FoundMongoDBUsers | Select-Object -Property Hostname, Username
    }
} catch {
    Write-Output "[$(Get-Date -Format yyyyMMdd)] An error occurred: $($_.Exception.Message)"
}