
Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"
#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$aud = $args[2]
[string]$tokenUrl = "https://$aud/oauth/token"
[string]$api = "$baseURL/restapi/v2.1"
[string]$iss = $args[3]
[string]$sub = $args[4]
[string]$privateKeyPEM = $args[5]
[string]$accountid = $args[6]
[string]$svcAcctGroupNames = $args[7]


#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Docusign-eSignature-Discovery.log"

[int32]$LogLevel = 2
[string]$logApplicationHeader = "Docusign eSignature Discovery"
[string]$scope ="signature impersonation"
#endregion

#region Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token"  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    
# Define your JSON Web Token (JWT)
$jwtToken = "$(Get-JWT -aud $aud -iss $iss -sub $sub -privkey $privateKeyPEM -scope $scope)"

# Set the headers
$headers = @{"Content-Type" = "application/x-www-form-urlencoded"}

# Make the POST request
$response = Invoke-RestMethod -Uri $tokenurl -Method POST -Headers $headers -Body "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$($jwtToken)" 

    # Extract the access token from the response
    $accessToken = $response.access_token

    
    Write-Log -Errorlevel 0 -Message "Access Token Successfuly Obtained " -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Docusign eSignature Access Token failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception
}
#endregion Get Access Token 

#region Discovery Filtering Functions
function isSvcAcct{
param(
$svcAccts,
$userId
)
try 
{
       
    foreach ($svcAcct in $svcAccts)
        {  $isSvcAcct = $false
            if($svcAcct.userId -eq $userId)
            {
                $isSvcAcct = $true
            
                break
            } 
        }
    }
catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception 
    }

return $isSvcAcct
}

#endregion

function islocal{
    param(
        $localaccts,
        $userid
    )
try {
    foreach($localacct in $localaccts)
    { 
        if($localacct.userid -eq $userid)
        {
        $isLocal = $true
        break
        }
    else{
        $islocal = $false
    }}
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Check if Local Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
    return $islocal
}

#region Get All Users
 #Create Headers
 try {
   
    $headers = @{
        "Authorization" = "Bearer $accesstoken"
        "Accept"        = "application/json"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    
    # Get All Active Users
    
    
    # Specify endpoint uri for Users
    $uri = "$api/accounts/$accountid/users?count=100"

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $users = Invoke-restmethod -Headers $headers -Method $method -Uri $uri -ContentType "application/json"
    $userlist = $users.users
    while($users.nextUri){$nexturi = $users.nexturi
        $users = Invoke-restmethod -Headers $headers -Method $method -Uri "$api/accounts/$accountid/$nextUri" -ContentType "application/json"
                          $userlist += $users.users
            }

    Write-Log -ErrorLevel 0 -Message "Successfully found $($userlist.Count) Total User Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception
}
#endregion


#region get admin users
    # Fetching users associated with this role(s)
function get-adminusers{
    param(
        $user
    )
    try{
          $isadmin = $false 
        if($user.isAdmin -eq $true -or $user.isalternateAdmin -eq $true)
        {
            $isadmin = $true
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to parse Admin Role List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
        }
    return $isadmin
}

#endregion Get Admin Users  

#region get Service Accounts

    # Fetching Accounts associated with this Group name(s)
function get-SvcAccounts{
    try {   
        If ($svcAcctGroupNames)
        { #Create array for multiple groupIds and users
            $svcActGroupIdArray = @()
            $svcAccountIds = @()
            ### Create Array of SvcAccount group names from arguments
            $svcActGroupNameArray = $svcAcctGroupNames.split(",") 
            #Pull a list of all groups and select the matches and store the IDs into an array
            $AllGroups = Invoke-RestMethod -Uri "$api/accounts/$accountid/groups" -Headers $headers 
            foreach($group in $svcActGroupNameArray){
            $svcAcctGroups = $AllGroups.groups | Where-Object groupname -EQ $group
            $svcActGroupIdArray += $svcAcctGroups
            }
        # Perform a search for each group ID and add matching users to an array
            foreach ($group in $svcActGroupIdArray) {
                $groupid = $group.groupid
                $svcAcctslist = Invoke-RestMethod -Uri "$api/accounts/$accountid/groups/$groupid/users" -Headers $headers
                $svcAccountIds += $svcAcctslist.users
                    }
                Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountIds.Count) Service Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        }
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accounts List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
    }
return $svcAccountIds
}

#endregion Get Service Account Users  
#region Get non-federated Local Users
function get-LocalAccounts{
    try{
        #Get All Users with additional_information=true
            # Specify endpoint uri for Local Users
    $uri = "$api/accounts/$accountid/users?additional_info=true&count=100"

    # Send HTTP request
    $Localusers = Invoke-restmethod -Headers $headers -Method Get -Uri $uri -ContentType "application/json"
    $Localuserlist = $Localusers.users
    Write-Log -ErrorLevel 0 -Message "Starting to query and process Local Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    while($Localusers.nextUri){$nexturi = $Localusers.nexturi
        $Localusers = Invoke-restmethod -Headers $headers -Method $method -Uri "$api/accounts/$accountid/$nextUri" -ContentType "application/json"
                          $Localuserlist += $Localusers.users
                          $nonfederatedUsers = $Localuserlist | where-object {$_.userSettings.federatedStatus -eq "none"}
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($nonfederatedUsers.Count) Local Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Local Accounts List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
    }
    return $nonfederatedUsers
}
#endregion
#region Main Process
#Region Get Advanced User Data
<#
    if Discovery Mode is set to default, parsing svcAccount groups is skipped
#>
$nonfederatedusers = get-localaccounts 

if($DiscoveryMode -eq "Advanced"){

    $svcAccountIds = get-SvcAccounts  
   
}
#endregion

#define Output Array
$foundAccounts = @()

Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    if($DiscoveryMode -eq "Default")
    {
        foreach ($user in $userlist)
                {   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.username
                    
                    $foundAccounts += $object
                    
                }
        }
    else{
        foreach ($user in $userlist)
        {      
            ### check if is admin

                    $isadmin = get-adminusers -user $user

            #Check Service Account
            if ($svcAcctGroupNames)
                {
                    $isServiceAccount = isSvcAcct -svcAccts $svcAccountIds -userId $user.userId
                }   
                else   
                {
                    $isServiceAccount = $false
                }                  
            #Check if Local Account

                 $islocal = islocal -localaccts $nonfederatedUsers -userid $user.userId              
                
                if(($isAdmin -eq $true -or $isServiceAccount -eq $true) -and $islocal -eq $true)
                {   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.username
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $islocal
                    
                    $foundAccounts += $object
                    
                    

                }
            }
           if($svcAcctGroupNames){ Write-Log -Errorlevel 0 -Message "List of Service Accounts defined by Service Account Group Names parameter: $($svcAcctGroupNames)"  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile}
        }
       
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Account Discovery-Filtering failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
#endregion Main Process
Write-Log -ErrorLevel 0 -Message "Successfully Found $($foundAccounts.Count) Matching Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
return $foundAccounts