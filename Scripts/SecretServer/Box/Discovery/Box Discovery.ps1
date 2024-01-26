
Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"
#Import-Module -Name ".\Delinea.PoSH.Helpers\Utils.psm1"
#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL ="https://api.box.com" 
[string]$tokenUrl = "$baseURL/oauth2/token" 
[string]$api = "$baseURL/2.0"
[string]$clientId = $args[1]
[string]$clientSecret = $args[2]
[string]$boxsubjecttype = $args[3]
[string]$boxsubjectid = $args[4]
[string]$adminroles = $args[5]
[string]$svcAcctGroupNames = $args[6]

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Box-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Box Discovery"
#endregion
#region Get Access Token
#Get Access Token

try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    # Prepare body for the token request
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        }
   #Get AuthCode from redirect URI

   
    $body = @{
                grant_type    = "client_credentials"
                box_subject_type = $boxsubjecttype 
                client_id     = $clientId
                client_secret = $clientSecret
                box_subject_id= $boxsubjectid
            }
    # Make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -Headers $headers

    # Extract the access token from the response
    $accessToken = $response.access_token
    
    Write-Log -Errorlevel 0 -Message "Box Access Token Successfuly Obtained " -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Box Access Token failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
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
        {  
            if($svcAcct.Id -eq $userId)
            {
                $isSvcAcct = $true
                break
            } 
            else{$isSvcAcct = $false}
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

function isAdmin{
    param(
        $AdminRoles,
        $userid
    )
try {
    #Check if member is part of an $adminRoles role
    foreach($role in $AdminRoles.split(","))
    {
        if($userid.role -eq $role)
        {
        $isadmin = $true
        break 
        }
    else{
        $isadmin = $false
    }
    }
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
    return $isAdmin
}

#region Get All Users
 #Create Headers
 try {
   
    $headers = @{
        "Authorization" = "Bearer $accesstoken"
        "Accept"        = "application/json"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

    # Specify HTTP method
    $method = "get"  
$userlist = @()
    # Get Workspaces
    $uri = "$api/users?fields=id,type,name,role,enterprise&usemarker=true"
    $users = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
    $userlist += $users.entries
    while($users.next_marker){$nexturi = $users.next_marker
        $users = Invoke-restmethod -Headers $headers -Method $method -Uri "$uri&marker=$nextUri" 
                          $userlist += $users.entries
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
            $AllGroups = Invoke-RestMethod -Uri "$api/groups?limit=1000" -Headers $headers 
            foreach($group in $svcActGroupNameArray){
            $svcAcctGroups = $AllGroups.entries | Where-Object name -EQ $group
            $svcActGroupIdArray += $svcAcctGroups
            }
        # Perform a search for each group ID and add matching users to an array
            foreach ($group in $svcActGroupIdArray) {
                $groupid = $group.id
                $svcAcctslist = Invoke-RestMethod -Uri "$api/groups/$groupid/memberships" -Headers $headers
                $svcAccountIds += $svcAcctslist.entries.user
                while($svcAcctslist.next_marker){$nexturi = $svcAcctslist.next_marker
                    $svcAcctslist = Invoke-restmethod -Headers $headers -Method $method -Uri "$uri&marker=$nextUri" 
                        $svcAccountIds += $svcAcctslist.entries.user }
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

if($DiscoveryMode -eq "Advanced"){

    if($svcAcctGroupNames){$svcAccountIds = get-SvcAccounts}
   
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
            $isAdmin = isAdmin -AdminRoles $adminRoles -userid $user
            $isSvcAcct = isSvcAcct -svcAccts $svcAccountIds -userId $user.id
            if(!$user.enterprise){$islocal = $true}else{$islocal = $false}

            if($isAdmin -eq $true -or $isSvcAcct -eq $true){   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $user.enterprise.name
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.name
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAcct
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $islocal
                    
                    $foundAccounts += $object
                    
            } 

                
            }
           if($adminroles) { Write-Log -Errorlevel 0 -Message "List of Admin Accounts defined by Admin Roles parameter: $($AdminRoles)"  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile}
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