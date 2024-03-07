# Script usage
# Use powershell script for password changing.
# Parameters to provide in each case are:

# Password Change: rpc $[1]$TenantID $[1]$applicationid $[1]$ClientSecret $username $password $newpassword


[string]$tenantid = $args[0]
[string]$clientid = $args[1]
[string]$clientsecret = $args[2]
[string]$thy_username = $args[3]
[string]$thy_newpassword = $args[4]
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
    Write-Log -Errorlevel 2 -Message "Old log data has been purged."
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

#ariable handling
if ($response) {
    Remove-Variable response
}

# Check if variables are actually set
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$tenantid -or !$clientid -or !$clientsecret -or !$thy_username -or !$thy_newpassword) {
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



#RPC
# Function to rotate password of managed account user application account
# The function will connect to Microsoft Graph using the application client id and client secret
# It will then set the password of the managed account without the requirement to know the current password
# It will also remove the requirement to set a new password on login
function Invoke-RPC {
    try {
        Write-Log -Errorlevel 0 -Message "Start Authentication towards TenantId: $TenantId for applicationID: $clientid"
        # Create client credentials and stored in creds variable using the clientid and clientsecret variables
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientid, (ConvertTo-SecureString -String $clientsecret -AsPlainText -Force)
        # Connect to Microsoft Graph using the client credentials
        Connect-MgGraph -ClientSecretCredential $creds -TenantId $tenantid -NoWelcome -ErrorAction Stop
        Write-Log -Errorlevel 0 -Message "Connected to: $TenantId with applicationID: $clientid"
    }
    catch {
        Write-Log -ErrorLevel 0 -Message "Failed to authenticated with provided application id / application secret"
        Write-Log -ErrorLevel 2 -Message $_.Exception
        throw "Failed to authenticated with provided application id / application secret"
    }
    
    # Get specific user from Azure AD
    $targetuser = Get-MgUser -Filter "userPrincipalName eq '$thy_username'"
    # if the user is not found. targetuser will be empty and the script should stop
    if (!$targetuser) {
        Write-Host "User not found"
        Write-Log -ErrorLevel 0 -Message "User not found"
        throw "User not found"
    }

    # Define parameters for password change
    $params = @{
        passwordProfile = @{
            forceChangePasswordNextSignIn = $false
            password = "$thy_newpassword"
        }
    }

    try {
        update-mguser -Userid $targetuser.Id -BodyParameter $params
    }
    catch {
        Write-Host "Password change failed for user: $thy_username"
        Write-Log -ErrorLevel 0 -Message "Password change failed for user: $thy_username"
        Write-Log -ErrorLevel 2 -Message $_.Exception
        throw "Password change failed"
    }
    Write-Log -ErrorLevel 0 -Message "Password change successful for user: $thy_username"
    write-host "Password change successful for user: $thy_username"

    # Disconnect from Microsoft Graph
    Disconnect-MgGraph
    Write-Log -ErrorLevel 0 -Message "Disconnected from Microsoft Graph"
}

 Invoke-RPC
