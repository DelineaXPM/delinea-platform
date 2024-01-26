#Args used for development (Remove before pushing to production):



Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"
#Import-Module -Name ".\Delinea.PoSH.Helpers\Utils.psm1"
#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL ="https://app.asana.com" 
[string]$api = "$baseURL/api/1.0"
[string]$PAToken = $args[1]
[string]$svcacctName = $args[2]
[string]$domainName = $args[3]

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Asana-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Asana Discovery"
#endregion
$accesstoken = $PAToken

#region Discovery Filtering Functions
function isSvcAcct{
param(
$svcAcctsName,
$userId
)
try 
{
       
    foreach ($svcAcct in $svcAcctsName.split(","))
        {  
            if($userid.user.name -like $svcacct)
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

    # Get Workspaces
    $uri = "$api/workspaces"
    $workspaces = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
    $workspaces = $workspaces.data
    $teamIds = @()
    #Get list of teams
    foreach($workspaceid in $workspaces){
        $uri = "$api/workspaces/$($workspaceid.gid)/teams"
        $teams = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
            $teamIds += $teams.data
    }
    $allusers =@()
    $optfields = "opt_fields=gid,name,email"
    $uri = "$api/users?$optfields"
    $usernames = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
    $allusers += $usernames.data   
while($usernames.offset){$nexturi = $usernames.offset
    $usernames = Invoke-restmethod -Headers $headers -Method $method -Uri "$api/$nextUri" -ContentType "application/json"
                    $allusers += $usernames.data
            } 

    Write-Log -ErrorLevel 0 -Message "Successfully found $($allusers.Count) Total User Accounts"   -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
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
        try{
              $userlist = @()
            foreach($team in $teamids){
                $optfields = "opt_fields=team.resource_type,team.name,offset,user.resource_type,user.name,is_admin,resource_type"
                $uri = "$api/team_memberships?team=$($team.gid)&$optfields"
                $users = Invoke-restmethod -Headers $headers -Method $method -Uri $uri
                $userlist += $users.data   
        while($users.offset){$nexturi = $users.offset
            $users = Invoke-restmethod -Headers $headers -Method $method -Uri "$api/$nextUri" -ContentType "application/json"
                                $userlist += $users.data
                        } 
                    }
            }
        
        catch {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Failed to parse Admin Role List" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            throw $Err.Exception  
            }
            return $userlist
    }

#endregion Get Admin Users  

#region Main Process
#Region Get Advanced User Data
<#
    if Discovery Mode is set to default, parsing svcAccount names and admin users is skipped
#>

if($DiscoveryMode -eq "Advanced"){

}
#endregion

#define Output Array
$foundAccounts = @()
$userlist = get-adminusers
Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    if($DiscoveryMode -eq "Default")
    {
        foreach ($user in $userlist)
                {   
                    $username = $allusers | Where-Object gid -eq $user.user.gid 
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $user.team.name
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username.email
                    
                    $foundAccounts += $object
                    
                }
        }
    else{
        foreach ($user in $userlist)
        {      
            ### check if is admin and svc account
            if($user.is_admin -eq $true){$isAdmin = $true}else{$isAdmin = $false}
            $isServiceAccount = isSvcAcct -svcAcctsName $svcacctName -userId $user
            $username = $allusers | Where-Object gid -eq $user.user.gid 
                if($username.email.split("@")[1] -eq $domainName){$isLocal = $false}else{$isLocal = $true}

               if($isadmin -eq $true -or $isServiceAccount -eq $true){  
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $user.team.name
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username.email
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
                    
                    $foundAccounts += $object
               }      

            }
            
            if($svcAcctNames){Write-Log -Errorlevel 0 -Message "List of Service Accounts defined by Service Account Naming Convention pattern(s) parameter: $($svcAcctNames)"  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile}
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