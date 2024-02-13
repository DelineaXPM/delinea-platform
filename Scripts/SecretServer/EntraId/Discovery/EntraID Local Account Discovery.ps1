# Script usage
# use powershell script for Discovering of EntraID/Azure/Office 365 Local Accounts.
# parameters to provide in each case are:
# Discovery $[1]$TenantID $[1]$applicationid $[1]$ClientSecret $username $password 

# we should be making this as a cmndlet that has forced args so we dont have to do these checks that are not needed
[string]$tenantid = $args[0] 
[string]$applicationid = $args[1] 
[string]$clientsecret = $args[2] 
[string]$adminCriteria = $args[3] 
[string]$svcAccountGeoups =  $args[4] 
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\EntraID-Connector.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "EntraID Discovery"
# Uncomment the line below to enable TLS 1.2 if needed
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Error Handling Fumctions
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel,$logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}

###   ###   ###   ###   ###  Log Cleanup  ###   ###   ###   ###   ###
if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old log data has been purged."
}

###   ###   ###   ###   ###    Modules    ###   ###   ###   ###   ###
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

# Check if variables are actually set
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$tenantid -or !$applicationid -or !$clientsecret ) {
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


#endregion

#region admin user functions

function get-AdminUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Admin users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are assigned AWS Permision Policies
    dmin Policiws are passwd in as a comma seperated list of the Policy name and arn KeyValue pair that Identify Administrators.
    
    .EXAMPLE
    An example: Admin Access = arn:aws:iam::aws:policy/AdministratorAccess",Custom Access=arn:aws:iam::aws:policy/Custom Access"
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        ##Create Roles Array
      
        If ($adminCriteria)
        {
            ### Create Array of Admin Roles
            
            #Clear Parametwr List
           $adminRoleArray = $adminCriteria.split(",").Split("=")[1] 
           $adminUsers = @()
            foreach ($roleID in $adminRoleArray  ) {
                    $roleID = $roleID.trim()
                    $roleUsers = Get-MgDirectoryRoleMember -DirectoryRoleId $roleID
                  
                    foreach($roleUserId in $roleUsers)
                    {
                        $adminUsers += $roleUserId
                    }

                   
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($adminUsers.Count) Admin Accounts"    
                

        }   
    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve admin User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception  
    }
 return $adminUsers
} 
function isadmin{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            
    
            foreach ($adminUser in $global:adminUsers)
            { 
                if($adminuser.id -eq $userId)
                {
                    $isadmin = $true
                    break
                } 
                else
                {
                    $isadmin = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isadmin  
}
#endregion Admin User Functions  

#region Service Account Functions
function get-svcAccountUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Service Account users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are members of 
    Service Account Groups Policiws are passwd in as a comma seperated list of Group Nmaes that Identify Service Account Users.
    
    .EXAMPLE
    An example: Service Team=0ee39126-67d5-4e2c-93cc-a78f32ccc78d
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        ##Create Roles Array
      
        If ($svcAccountGeoups)
        {
            ### Create Array of Serice Account Groups
            $svcGroupArray = $svcAccountGeoups.split(",").Split("=")[1]
            #Clear Parametwr List
          
           $svcUsers = @()
            
                   
                    foreach($Group in $svcGroupArray )
                    {
                        
                        $results =Get-MgGroupMember -GroupId $Group
                    
                        foreach ($groupUser in $results) {
                            $svcUsers +=  $groupUser.Id
                         
                        }
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcUsers.Count) Service Accounts"    
                

        }   
    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve admin User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception  
    }
 return $svcUsers
} 

function isSvcAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            
    
            foreach ($svcAcctUser in $global:svAcctUsers)
            { 
                if($svcAcctUser -eq $userId)
                {
                    $isSvcAcct = $true
                    break
                } 
                else
                {
                    $isSvcAcct = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isSvcAcct  
}




#endregion
###   ###   ###   ###   ###    HB    ###   ###   ###   ###   ###
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



# Create client credentials and stored in creds variable using the clientid and clientsecret variables
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationid, (ConvertTo-SecureString -String $clientsecret -AsPlainText -Force)

# Connect to Microsoft Graph using the client credentials
Connect-MgGraph -ClientSecretCredential $creds -TenantId $tenantid -NoWelcome -ErrorAction Stop



Write-Log -Errorlevel 0 -Message "Connected to: $TenantId with applicationID: $clientid"

Write-Log -Errorlevel 0 -Message "Retrieving User List"
try {
    $global:adminUsers = @()
    $global:svAcctUsers = @()
    $global:adminUsers = get-AdminUsers
    $global:svAcctUsers = get-svcAccountUsers
    $users = Get-MgUser -Filter 'accountEnabled eq true' -All -Property *
    $foundAccounts = @()
    foreach($user in $users)
    {
      $userId = $user.Id
      $isAdmion  = isadmin -userId $userId  
      $isSvcAccount = isSvcAccount -userId $userId
      if ( $user.userPrincipalName.Contains("#EXT#") -eq $false)
      {
        $isLocal = $true
        $userName = $user.UserPrincipalName
      }
      else {
        $isLocal = $false
        $userName = $user.UserPrincipalName
      }
      if($isAdmion -or $isSvcAccount) 
      {
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name username -Value $userName
        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $user.id

        
        $foundAccounts += $object
      }



      
    }
}
catch {
    #Do this if a terminating exception happens
}

return $foundAccounts
