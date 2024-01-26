
Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"

#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL ="https://api.confluent.cloud" 
[string]$confluentcloudURL = "https://confluent.cloud"
[string]$api = "$baseURL/iam/v2"
[string]$key = $args[1]
[string]$secret = $args[2]
[string]$adminroles = $args[3]

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($key):$($secret)"))

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Confluent-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Confluent Discovery"
#endregion
#region Get Access Token


#region Discovery Filtering Functions


function isAdmin{
    param(
        $AdminUsers,
        $userid
    )
try {
    #Check if member is part of an $adminRoles role
    foreach($user in $AdminUsers)
    {
        if($userid.id -eq $user)
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

function isLocal{
    param(
        $user
    )
try {
    #Check if member has local auth type
    if($user.auth_type -like "AUTH_TYPE_LOCAL"){$isLocal = $true}
    else{$isLocal = $false}
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
        "Authorization" = "Basic $base64AuthInfo"
        "Accept"        = "application/json"
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

    # Specify HTTP method
    $method = "get"  
$userlist = @()
    # Get Workspaces
    $uri = "$api/users"
    $users = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
    $userlist += $users.data
    while($users.metadata.next){$nexturi = $users.metadata.next
        $users = Invoke-restmethod -Headers $headers -Method $method -Uri $nexturi 
                          $userlist += $users.data
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
#region get Admin Accounts

    # Fetching Accounts associated with this Role name(s)
    function get-AdminAccounts{
        try {   
            If ($AdminRoles)
            { #Create array for multiple RoleIds and users
                $AdminRolesArray = @()
                $AdminAccountIds = @()
                $AllRoles        = @()
                $adminAccounts   = @()
                ### Create Array of admin role names from arguments
                $AdminRolesArray = $AdminRoles.split(",") 
                #Pull a list of all roles from the enterprise and select the matches and store the IDs into an array
                $orgs = Invoke-RestMethod -Headers $headers -Method Get -Uri "$baseURL/org/v2/organizations"
                foreach($org in $orgs){
                    $orgid = $org.data.id
                $OrgRoles = Invoke-RestMethod -Uri "$api/role-bindings?crn_pattern=crn://confluent.cloud/organization=$orgid" -Headers $headers -Method get
                    $AllRoles += $OrgRoles.data
                }
                foreach($role in $AdminRolesArray){
                $AdminRoleIds = $AllRoles | Where-Object role_name -EQ $role
                $AdminAccountIds += $AdminRoleIds
                }
            # Perform a search for each group ID and add matching users to an array
                foreach ($role in $AdminAccountIds) {
                    $UserPrincipals = $($role.principal.split(",") | ForEach-Object {if($_ -like 'user:*'){$_.split(":")[1]}})
                        $adminAccounts += $UserPrincipals
                }
                    Write-Log -ErrorLevel 0 -Message "Successfully found $($adminUsers.Count) Matching Admin Assignments"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
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
    
    #endregion Get Service Account Users  

#region get Service Accounts

    # Fetching Accounts associated with datatype (Kind) = ServiceAccount
function get-SvcAccounts{
    try {
        $svcAccountsIds = @()
        $svcAccounts = Invoke-RestMethod -Uri "$api/service-accounts" -Method Get -Headers $headers   
        $svcAccountsIds += $svcAccounts.data
        while($svcAccounts.metadata.next){$nexturi = $svcAccounts.metadata.next
            $svcAccounts = Invoke-restmethod -Headers $headers -Method $method -Uri $nexturi 
                 $svcAccountsIds += $svcAccounts.data
                }
        Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountsIds.Count) Matching Service Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accounts List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $Err.Exception  
    }
return $svcAccountsIds
}

#endregion Get Service Account Users  

if($DiscoveryMode -eq "Advanced"){
    $adminAccounts = get-AdminAccounts
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
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $confluentcloudURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                    
                    $foundAccounts += $object
                    
                }
        }
    else{
        foreach ($user in $userlist)
        {      
            ### check if is admin and local
            $isAdmin = isAdmin -AdminUsers $adminAccounts -userid $user
            $isLocal = isLocal -user $user
            if($user.kind -like "ServiceAccount"){$isSvcAcct = $true}else{$isSvcAcct = $false}

            if($isAdmin -eq $true -and $islocal -eq $true){   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $confluentcloudURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAcct
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $islocal
                    
                    $foundAccounts += $object
                    
            }                
            }
            foreach ($svcAcct in $svcAccountIds)
            {
                if($svcAcct.kind -like "ServiceAccount"){$isSvcAcct = $true}else{$isSvcAcct = $false}
                $isAdmin = isAdmin -AdminRoles $adminRoles -userid $svcAcct
                 
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $confluentcloudURL
                $object | Add-Member -MemberType NoteProperty -Name username -Value $svcAcct.display_name
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAcct
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                
                $foundAccounts += $object
                
        } 
           if($adminroles) { Write-Log -Errorlevel 0 -Message "List of Admin Accounts defined by Admin Roles parameter: $($AdminRoles)"  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile}
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