[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region define variables
#Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$tokenUrl = "$baseURL/api/oauth/token"
[string]$proapi = "$baseURL/api"
[string]$classicapi = "$baseURL/JSSResource"
[string]$clientId = $args[2]
[string]$clientSecret = $args[3]
[string]$adminRole= $args[4] #Labeled as PrivilegeSet by Jamf
[string]$svcAcctGroupId = $args[5]

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Jamf-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Jamf Discovery"
#endregion

#region Error Handling Functions
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
        # $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        # Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}
#endregion Error Handling Functions


#region Get Access Token
#Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token"
    # Prepare body for the token request
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        }
   
    $body = @{
                grant_type    = "client_credentials"
                client_id     = $clientId
                client_secret = $clientSecret
            }
    # Make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -Headers $headers

    # Extract the access token from the response
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
<# The isAdmin and isSvcAcct Functions will not be used in Default mode#>
function isadmin{
    param(
    $adminUsers,
    $userId
    )

    try
        {
            foreach ($adminUser in $adminUsers)
            { 
                if($adminUser.id -eq $userId)
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
            Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception 
        }
            
    $isadmin
}
function isSvcAcct{
param(
$svcAccts,
$userId
)
        try 
        {
        if(!$svcaccts){$isSvcAcct = $false}
        else{
            foreach($svcacct in $svcAccts){
                if($svcAcct.id -eq $userid)
            {
                $isSvcAcct = $true
                break
            } 
            else
            {
                $isSvcAcct = $false
            }
        }}
            }
    
catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }

return $isSvcAcct
}
function isLocal{
    param(
    $localUsers,
    $userId
    )
    try
    {
      $localuserlist = $localusers.account | Where-Object directory_user -like 'False'
        foreach($user in $localuserlist){
            if($user.id.equals($userid) -eq $true){
                $islocal = $true
                break 
            }
            else {
                $islocal = $false
            }
        }
    }
    catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Is Local Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception     }        
  return $isLocal
}
#endregion

#region Get All Users

 try {
    #Create Headers
    $headers = @{
    "Authorization" = "Bearer $accessToken"     
    "Accept" = "application/json, application/json"
    "Content-Type" = "application/json, application/json"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    
    # Get All Active Users
    # Specify Pro API endpoint uri for Users
    $uri = "$proapi/user"

    # Specify HTTP method
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
# Fetching users associated with the $AdminRoles roles (privilege_set)
function get-AdminUsers{
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        ##Create Roles Array
      
        If ($adminRole)
        {
            ### Create Array of Admin Roles

            $adminRoleArray = $adminRole.split(",") 
            foreach ($role in $adminRoleArray) {
                # Users can only have one role (Privilege_Set) at a time. Add respective users from each role to the same array:
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

# Fetching Accounts associated with this/these Group/s
function get-SvcAccounts{
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Accounts"       
        ##Create Roles Array
        If ($svcAcctGroupId)
        { 
            ### Create Array of SvcAccount Roles
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
function get-LocalUsers{
    try{ 
 #Leverage the Classic API to distinguish between Directory_Users and Local users. 

        $headers = @{
        "Authorization" = "Bearer $accessToken"     
        "Accept" = "application/json, application/json"
        "Content-Type" = "application/json, application/json"
        }
        
            Write-Log -Errorlevel 0 -Message "Obtaining List of Local Users"    
            
            # Specify Classic API endpoint uri for Users (Labeled as Accounts in these endpoints)
            $uri = "$classicapi/accounts"
        
            # Specify HTTP method
            $method = "get"
        
            # Send HTTP request
            $LocalusersIds = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri
        # Create array for each user's information
          $localusers = @(foreach($localuser in $localusersIds.accounts.users.id){
                Invoke-RestMethod -Uri "$uri/userid/$localuser" -Headers $headers})
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
<#
    if Discovery Mode is set to default, only the get-LocalAccounts will be run
#>

if($DiscoveryMode = "Advanced"){

  $adminUsers =  get-AdminUsers  
  $svcAccountIds = get-SvcAccounts  

}
$LocalUsers = get-LocalUsers
#endregion

#define Output Array
$foundAccounts = @()

Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Filtering Discovered Users"  
    if($DiscoveryMode -eq "Default")
    {
        foreach ($user in $users)
        {
            $userId = $user.id
            
            ###check is Local
          $isLocal = isLocal -localUsers $LocalUsers -userId $userId
      
                if($isLocal -eq $true)
                {   
                
                    $Username = $user.username

                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                    
                    $foundAccounts += $object
                    
                }
            }
        }
    else{
        foreach ($user in $users)
        { 
            ### check if is admin
            if($adminRole) 
            {
                $isadmin = isadmin -adminUsers $adminUsers -userId $user.id
            }
            else 
            {
                $isadmin = "N\A"
            }

            #Check Service Account
            if ($svcAcctGroupId)
                {
                    $isServiceAccount = isSvcAcct -svcAccts $svcAccountIds -userId $user.Id
                }   
                else   
                {
                    $isServiceAccount = $false
                }                  

            #check is Local

                    $isLocal = isLocal -localUsers $LocalUsers -userId $user.Id
                
         
            if(($isAdmin -eq $true -or $isServiceAccount -eq $true ) -and $isLocal -eq $true )
                {   
                
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