Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"

#region define variables
#Define Argument Variables

[string]$api = "https://graph.microsoft.com/v1.0"
[string]$tenantid = $args[0]
[string]$clientid = $args[1]
[string]$clientsecret = $args[2]
[string]$adminroles = $args[3]
[string]$svcAcctGroups = $args[4]
[string]$localDomain = $args[5]


#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Intune-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Intune Discovery"
#endregion
#region Get Access Token
#Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

    # Make a POST request to obtain the token
    $response = Get-MicrosoftPlaformToken -clientid $clientid -clientsecret $clientsecret -tenantid $tenantid

    # Extract the access token from the response
    $accessToken = $response
    
    Write-Log -Errorlevel 0 -Message "Azure Access Token Successfuly Obtained " -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Azure Access Token failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception
}


#region Discovery Filtering Functions


function isAdmin {
    param(
        $AdminUsers,
        $userid
    )
    try {
        #Check if member is part of an $adminRoles role
        foreach ($user in $AdminUsers) {
            if ($userid.id -eq $user.id) {
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
        Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception 
    }
    return $isAdmin
}

function isSvcAcct {
    param(
        $svcAccts,
        $userId
    )
    try {
           
        foreach ($svcAcct in $svcAccts) {
            if ($svcAcct.id -eq $userId.id) {
                $isSvcAcct = $true
                break
            } 
            else {  
                $isSvcAcct = $false
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
        $user
    )
    try {
        #Check if member has local auth type
        if ($user.userPrincipalName.Contains($localDomain) -eq $true) { $isLocal = $true }
        else { $isLocal = $false }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Local Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception 
    }
    return $isLocal
}

#endregion
#region Get All Users
#Create Headers
try {
   
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Accept"        = "application/json"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

    # Specify HTTP method
    $method = "get"  
    $userlist = @()
    # Get Workspaces
    $uri = "$api/users"
    $userlist = @()
    $users = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers 
    $userlist += $users.value
    # Pagination
    while ($users.'@odata.nextLink') {
        $nexturi = $users.'@odata.nextLink'
        $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $nexturi 
        $userlist += $users.value
    }

    Write-Log -ErrorLevel 0 -Message "Successfully found $($userlist.Count) Total User Accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception
}
#endregion
#region get Admin Accounts

# Fetching Accounts associated with this Role name(s)
function get-AdminAccounts {
    try {   
        If ($AdminRoles) {
            $AdminRoleIds = @()
            # Get a list of all Intune Roles
            $IntuneRoles = Invoke-RestMethod -Uri "$api/deviceManagement/roleDefinitions" -Method get -Headers $headers
            foreach ($role in $adminroles.Split(",")) {  
                # Match admin roles from parameters
                $adminRoleIds += $IntuneRoles.value | Where-Object displayName -EQ $role
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($adminRoleIds.Count) matching Intune Admin Roles" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            if ($adminroleIds) {
                $AdminAssignments = @()
                $AdminGroups = @()
                $adminAccounts = @()
                foreach ($id in $adminroleids) {
                    $roleId = $id.id
                    # Get Role Assignments per role
                    $AdminAssignmentIds = Invoke-RestMethod -Uri "$api/deviceManagement/roleDefinitions/$roleid/roleAssignments" -Method get -Headers $headers
                    $AdminAssignments = $AdminAssignmentIds.value
                    foreach ($assignment in $AdminAssignments) {
                        $assignmentId = $assignment.id 
                        # Get groups assigned per Role Assignment
                        $adminMembers = Invoke-RestMethod -Uri "$api/deviceManagement/roleDefinitions/$roleid/roleAssignments/$assignmentId" -Method get -Headers $headers
                        # Add all groups into a single array
                        $adminGroups += $adminMembers.members.split(",")
                    }
                }
                foreach ($adminGroup in $adminGroups) {
                    # Get members from each group in the adminGroups array
                    $adminMembership = Invoke-RestMethod -Uri "$api/groups/$admingroup/members" -Headers $headers -Method get
                    $adminAccounts += $adminMembership.value
                    # Pagination
                    while ($adminMembership.'@odata.nextLink') {
                        $nexturi = $adminMembership.'@odata.nextLink'
                        $adminMembership = Invoke-RestMethod -Headers $headers -Method $method -Uri $nexturi 
                        $adminAccounts += $adminMembership.value
                    }
                }
              
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($adminAccounts.Count) matching Admin Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        }
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Admin Accounts List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
    }
    return $AdminAccounts
}
    
#endregion 

#region get Service Accounts
function get-SvcAccounts {
    try {   
        ##Create Roles Array
        If ($svcAcctGroups) {
            #Create array for multiple groupIds and users
            $svcActGroupIdArray = @()
            $svcAccountIds = @()
            ### Create Array of SvcAccount group names from arguments
            $svcActGroupNameArray = $svcAcctGroups.split(",") 
            #Pull a list of all groups and select the matches and store the IDs into an array
            $AllGroups = Invoke-RestMethod -Uri "$api/groups" -Headers $headers -Method get
            foreach ($group in $svcActGroupNameArray) {
                $svcAcctGroupIds = $AllGroups.value | Where-Object displayname -EQ $group
                $svcActGroupIdArray += $svcAcctGroupIds
            }
            # Perform a search for each group ID and add matching users to an array
            foreach ($group in $svcActGroupIdArray) {
                $groupid = $group.id
                $svcAcctslist = Invoke-RestMethod -Uri "$api/groups/$groupid/members" -Headers $headers -Method Get
                $svcAccountIds += $svcAcctslist.value 
                # Pagination
                while ($svcAcctslist.'@odata.nextLink') {
                    $nexturi = $svcAcctslist.'@odata.nextLink'
                    $svcAcctslist = Invoke-RestMethod -Headers $headers -Method $method -Uri $nexturi 
                    $svcAccountIds += $svcAcctslist.value
                }
            }
            Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountIds.Count) Service Accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        }
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accounts List"-logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
    }
    return $svcAccountIds
}
#endregion Get Service Accounts

#define Output Array
$foundAccounts = @()
$adminAccounts = get-AdminAccounts
$svcAccountIds = get-SvcAccounts
Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    foreach ($user in $userlist) {      
        ### check if is admin and local
        $isAdmin = isAdmin -AdminUsers $adminAccounts -userid $user
        $isLocal = isLocal -user $user
        $isSvcAcct = isSvcAcct -userId $user -svcAccts $svcAccountIds

        if (($isAdmin -eq $true -or $isSvcAcct -eq $true)) {   
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name username -Value $user.userPrincipalName
            $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
            $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAcct
            $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $islocal
                    
            $foundAccounts += $object
                    
        }                
            
    } 
    if ($adminroles) { Write-Log -Errorlevel 0 -Message "List of Admin Accounts defined by Admin Roles parameter: $($AdminRoles)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile }
    if ($svcAcctGroups) { Write-Log -Errorlevel 0 -Message "List of Service Accounts defined by Service Account Group Membership parameter: $($svcAcctGroups)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile }
    if ($localDomains) { Write-Log -Errorlevel 0 -Message "List of Local Accounts defined by Local Account Domain parameter: $($localDomains)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile }     
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Account Discovery-Filtering failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
#endregion Main Process
Write-Log -ErrorLevel 0 -Message "Successfully Found $($foundAccounts.Count) Matching Accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
return $foundAccounts