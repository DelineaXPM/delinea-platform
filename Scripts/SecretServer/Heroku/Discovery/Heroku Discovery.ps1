#Args used for development (Remove before pushing to production):



Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"

#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$apiKey = $args[1]
[string]$teamName = $args[2]
[string]$adminRoles = $args[3]
[string]$svcacctNamePrefixes = $args[4]


#Script Constants
[string]$baseURL = "https://api.heroku.com"  # This the URL for all Heroku Tenents
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Heroku-Discovery.log"

[int32]$LogLevel = 2
[string]$logApplicationHeader = "Heroku Discovery"

#create Arrays
$adminRolesArray = $adminRoles.split(",")
$svcacctNamePrefixeArray = $svcacctNamePrefixes.Split(",")

#endregion



#region Discovery Filtering Functions

function isSvcAcct{
param(
[string]$userName
)
try 
{
       
    foreach ($svcAcctPrefix in $svcacctNamePrefixeArray)
        {  
            $svcAcctPrefix =$svcAcctPrefix.Trim()
            if($userName.IndexOf($svcAcctPrefix) -eq  0)
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

function isAdminAcct{
    param(
    $userRole
    )
    try 
    {
           
        foreach ($role in $adminRolesArray)
            {  
                $role = $role.Trim()
                if($role-like $userRole)
                {
                    $isAdminAcct = $true
                
                    break
                } 
            else{$isAdminAcct = $false}
            }
        }
    catch 
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            throw $Err.Exception 
        }
    
    return $isAdminAcct
    }

#endregion




#region get admin users
    # Fetching users associated with this role(s)
 
#endregion Get Admin Users  

#region Main Process

#creatte Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", 'application/json')
$headers.Add("Authorization", "Bearer $apikey")
$headers.Add("Accept", "application/vnd.heroku+json; version=3")

# Get all users
$url = "$baseURL/teams/$TeamNAme/members"
$userlist = Invoke-RestMethod -uri $url -Headers $headers




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
            $userName = $user.email
            ### check if is admin and svc account
            $isAdmin = isAdminAcct -userRole $user.role
            
            $isServiceAccount = isSvcAcct -userName $userName
            
            if ($user.federated)
                {
                    $isLocal = $false
                }
                else 
                {
                    $isLocal = $true        
                }
            

               
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $teamName
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
                    
                    $foundAccounts += $object
                     

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