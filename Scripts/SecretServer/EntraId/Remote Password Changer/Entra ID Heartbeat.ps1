# Script usage
# Use powershell script for hearthbeat 
# Parameters to provide in each case are:
# $[1]$TenantID $[1]$applicationid $[1]$ClientSecret $username $password 



[string]$tenantid = $args[0]
[string]$clientid = $args[1]
[string]$clientsecret = $args[2]
[string]$thy_username = $args[3]
[string]$thy_password = $args[4]

[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\EntraID_rpc.log"
[int32]$LogLevel = 2


function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,1,2,3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message
    )
    # Evaluate Log Level based on global configuration
    if ($ErrorLevel -le $LogLevel) {
        # Format message
        [string]$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm:sszzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        # Write Log data
        $MessageString = "{0}`t| {1}`t| {2}" -f $Timestamp, $MessageLevel, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}

#Log Cleanup
if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old logdata has been purged."
}

#Modules
try {
    Write-Log -Errorlevel 0 -Message "Loading Microsoft Graph PowerShell modules"
    # Modules needed for Microsoft Graph Powershell
    Import-Module Microsoft.Graph.Users.Actions -ErrorAction Stop
} catch {    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to load Microsoft Graph PowerShell modules"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

#Variable handling
if ($response) {
    Remove-Variable response
}

# Check if variables are actually set
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$tenantid -or !$clientid -or !$clientsecret -or !$thy_username -or !$thy_password) {
    # If variables are not set, the script will stop
    Write-Log -Errorlevel 0 -Message "One or more variables are not set"
    throw "One or more variables are not set"
}

# If tenantid or any other variable contains $[1] the script will stop
if ($tenantid -like '$[1]*' -or $clientid -like '$[1]*' -or $clientsecret -like '$[1]*' -or $thy_username -like '$*' -or $thy_password -like '$*') {
    Write-Log -Errorlevel 0 -Message "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
    throw "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
}

# Check when action is rpc if new password variable is set
if ($action -eq 'rpc') {
    if (!$thy_newpassword -or $thy_newpassword -like '$newpassword') {
        Write-Log -Errorlevel 0 -Message "New password variable is not set"
        throw "New password variable is not set"
    }
}
Write-Log -Errorlevel 0 -Message "All variables correctly set"

# HB
# Function to try and authenticate to the Microsoft Graph API using the Resource Owner Password Credentials Grant
# The resulting token is not further used. The authentication request is just to validate the credentials
function Invoke-HB {
    # Define authentication URL
    $authUrl = "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token"
    # Build Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", 'application/x-www-form-urlencoded')
    # Define body of the request while using the defined variables
    $body = @{
        client_id = $clientid
        client_secret = $clientsecret
        scope = "https://graph.microsoft.com/.default"
        username = $thy_username
        password = $thy_password
        grant_type = "password"
    }
    # Invoke the request and perform authentication.
    # Response gets stored in variable $response
    # If a user is MFA enabled, the authentication will fail with a message
    # Part of the message is: you must use multi-factor authentication to access
    # This indicates the credentials are correct, but MFA is required
    # In other cases, the authentication will fail with an error message
    Write-Log -Errorlevel 0 -Message "Start Authentication towards TenantId: $TenantId for user $thy_username"
    try {
        $response = Invoke-WebRequest -Uri $authUrl -Method POST -headers $headers -Body $body
        # On a succesful authentication, the response code will be 200 which will be available in $response.StatusCode
        # In the unlikely event the authentication succeeds but the response code is not 200, the authentication is considered failed
        if ($response.StatusCode -eq 200) {
            Write-Log -Errorlevel 0 -Message "Authentication Successful for user $thy_username"
            Write-Output "Authentication Successful"
        } else {
            Write-Output "Authentication Failed"
            Write-Log -Errorlevel 0 -Message "Authentication Failed. Check credentials and / or API access permissions"
            throw "Authentication Failed. Check credentials and / or API access permissions"
        }
    } catch {
        # If the authentication fails, the error message is parsed to determine the cause of the failure
        # Invoke-webrequest goes into error mode when the response code is not indicating success
        $errormessage = $_.ErrorDetails | ConvertFrom-Json
        # If the error message contains the string 'multi-factor', the authentication is considered succesful
        # If the error message contains the string 'invalid', the authentication is considered failed
        # All other error messages are considered unknown and the authentication is considered failed
        if ($errormessage.error_description -like '*multi-factor*') {
            Write-Log 0 -Message "Authentication Successful for user $thy_username - MFA protected account"
            write-log -ErrorLevel 3 -Message $errormessage.error_description
            Write-Output "Authentication Successful for user $thy_username - MFA protected account"
        } elseif ($errormessage.error_description -like '*invalid*') {
            write-log -ErrorLevel 0 -Message "Authentication Failed. Check credentials and / or API access permissions"
            write-log -ErrorLevel 2 -Message $errormessage.error_description
            throw "Authentication Failed. Check credentials and / or API access permissions"
        } else {
            write-log -ErrorLevel 0 -Message "Authentication Failed. Unknown error occurred. Does the user exist?"
            write-log -ErrorLevel 2 -Message $errormessage.error_description
            throw "Authentication Failed. Unknown error occurred. Does the user exist?"
        }
    }
}


    Invoke-HB
