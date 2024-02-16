[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region define variables
#define Argument Variables
[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$clientId = $args[2]
[string]$clientSecret = $args[3]
[string]$adminRole = $args[4]
[string]$svcAcctGroupId = $args[5]
[string]$tokenUrl = "$baseURL/api/oauth/token"
[string]$proapi = "$baseURL/api"
[string]$classicapi = "$baseURL/JSSResource"

#script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Jamf-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Jamf Discovery"
#endregion

#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0, 1, 2, 3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory, ValueFromPipeline)]
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel, $logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}
#endregion Error Handling Functions
#region Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token"
    #prepare body for the token request
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }
   
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
    }
    #make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -Headers $headers
    #extract the access token from the response
    $accessToken = $response.access_token
    Write-Log -Errorlevel 0 -Message "Jamf Access Token Successfuly Obtained "
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Jamf Access Token failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Get Access Token
#region Discovery Filtering Functions
function isadmin {
    param(
        $adminUsers,
        $userId
    )
    try {
        foreach ($adminUser in $adminUsers) { 
            if ($adminUser.id -eq $userId) {
                $isadmin = $true
                break
            } 
            else {
                $isadmin = $false
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $isadmin
}
function isSvcAcct {
    param(
        $svcAccts,
        $userId
    )
    try {
        if (!$svcaccts) { $isSvcAcct = $false }
        else {
            foreach ($svcacct in $svcAccts) {
                if ($svcAcct.id -eq $userid) {
                    $isSvcAcct = $true
                    break
                } 
                else {
                    $isSvcAcct = $false
                }
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $isSvcAcct
}
function isLocal {
    param(
        $localUsers,
        $userId
    )
    try {
        $localuserlist = $localusers.account | Where-Object directory_user -Like 'False'
        foreach ($user in $localuserlist) {
            if ($user.id.equals($userid) -eq $true) {
                $islocal = $true
                break 
            }
            else {
                $islocal = $false
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if is Local Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $isLocal
}
#endregion
region Get All Users
try {
    #Create Headers
    $headers = @{
        "Authorization" = "Bearer $accessToken"     
        "Accept"        = "application/json, application/json"
        "Content-Type"  = "application/json, application/json"
    }
    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    #get all active users
    #specify pro API endpoint uri for users
    $uri = "$proapi/user"
    $method = "get"
    # Send HTTP request
    $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri
}
catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion
#region get admin users
fetching users associated with the $AdminRoles roles (privilege_set)
function get-AdminUsers {
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        #create roles array
      
        If ($adminRole) {
            #create array of admin roles

            $adminRoleArray = $adminRole.split(",") 
            foreach ($role in $adminRoleArray) {
                #users can only have one role (Privilege_Set) at a time. Add respective users from each role to the same array:
                $adminUsers += $users | Where-Object PrivilegeSet -EQ $Role
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($adminUsers.result.Count) Admin Accounts"    
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
#endregion Get Admin Users
#region get Service Accounts

#fetching Accounts associated with the group(s)
function get-SvcAccounts {
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Accounts"       
        #create roles array
        If ($svcAcctGroupId) { 
            #create array of SvcAccount roles
            $svcActGroupIdArray = $svcAcctGroupId.split(",") 
            foreach ($group in $svcActGroupIdArray) {
                $svcAccts += $users | Where-Object groupIds -Contains $group
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountIds.result.Count) Service Accounts"  
        }
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accounts List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }
    return $svcAccountIds
}
#endregion Get Service Accounts
#region Get Local Users
function get-LocalUsers {
    try { 
        #leverage the classic API to distinguish between Directory_Users and Local users. 
        $headers = @{
            "Authorization" = "Bearer $accessToken"     
            "Accept"        = "application/json, application/json"
            "Content-Type"  = "application/json, application/json"
        }
        Write-Log -Errorlevel 0 -Message "Obtaining List of Local Users"    
        #specify Classic API endpoint uri for users (Labeled as Accounts in these endpoints)
        $uri = "$classicapi/accounts"
        $method = "get"

        #send HTTP request
        $LocalusersIds = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri
        #create array for each user's information
        $localusers = @(foreach ($localuser in $localusersIds.accounts.users.id) {
                Invoke-RestMethod -Uri "$uri/userid/$localuser" -Headers $headers
            })
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    Write-Log -ErrorLevel 0 -Message "Successfully found $($LocalUsers.result.Count) Local Accounts"       
    return $LocalUsers
}
#endregion Get Local Users

#region Main Process

#Region Get Advanced User Data
#if $discoveryMode Mode is set to default, only the get-LocalAccounts will be run
if ($DiscoveryMode = "Advanced") {
    $adminUsers = get-AdminUsers  
    $svcAccountIds = get-SvcAccounts
}
$LocalUsers = get-LocalUsers
#endregion

#define Output Array
$foundAccounts = @()
Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Filtering Discovered Users"  
    if ($DiscoveryMode -eq "Default") {
        foreach ($user in $users) {
            $userId = $user.id
            #check is Local
            $isLocal = isLocal -localUsers $LocalUsers -userId $userId
            if ($isLocal -eq $true) {   
                $Username = $user.username
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $baseURL
                $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                $foundAccounts += $object
            }
        }
    }
    else {
        foreach ($user in $users) { 
            #check if is admin
            if ($adminRole) {
                $isadmin = isadmin -adminUsers $adminUsers -userId $user.id
            }
            else {
                $isadmin = "N\A"
            }
            #check service account
            if ($svcAcctGroupId) {
                $isServiceAccount = isSvcAcct -svcAccts $svcAccountIds -userId $user.Id
            }   
            else {
                $isServiceAccount = $false
            }                  
            #check is Local
            $isLocal = isLocal -localUsers $LocalUsers -userId $user.Id
            if (($isAdmin -eq $true -or $isServiceAccount -eq $true ) -and $isLocal -eq $true ) {   
                $Username = $user.username
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL
                $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
                    
                $foundAccounts += $object
            }
        }
    }
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Account Discovery-Filtering failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Main Process
Write-Log -ErrorLevel 0 -Message "Successfully Filtered $($foundAccounts.Count) total users."
return $foundAccounts