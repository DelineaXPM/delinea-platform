#Args used for development (Remove before pushing to production):


Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"

[string]$DiscoveryMode = $args[0]
[string]$api = "https://api.thousandeyes.com/v7"
[string]$accesstoken = $args[1]
[string]$adminroles = $args[2]
[string]$svcAccountRoles = $args[3]
[string]$LocalDomain = $args[4]

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ThousandEyes-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "ThousandEyes Discovery"

#region Get Users
$headers = @{
    "Authorization" = "Bearer $accesstoken"
    "Accept"        = "application/hal+json"
}
#Get User IDs
Write-Log -Errorlevel 0 -Message "Obtaining List of Users" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile

$users = Invoke-RestMethod -Method GET -Uri "$api/users" -Headers $headers

#Get User details and store into array
$userlist = @()
foreach($user in $users.users){
    $userdetails = Invoke-RestMethod -Method get -Uri "$api/users/$($user.uid)" -Headers $headers
    $userlist += $userdetails
}

#endregion Get Users

#region Discovery filtering functions
function isadmin{
    param(
        $userId,
        $adminroles
    )
try{
    $user = $userlist | where-object uid -eq $userid.uid
    if($user.allAccountGroupRoles){
    $compare = (Compare-Object -ReferenceObject $adminroles.split(",") -DifferenceObject $user.allAccountGroupRoles.name -IncludeEqual) | Where-Object SideIndicator -eq "=="
    }
    if($compare){$isadmin = $true}
    else{$isadmin = $false}
    
}
catch{
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
return $isadmin
}

function isServiceAccount{
    param(
        $userId,
        $svcAccountRoles
    )
try{
    $user = $userlist | where-object uid -eq $userid.uid
    if($user.allAccountGroupRoles){
    $compare = (Compare-Object -ReferenceObject $svcAccountRoles.split(",") -DifferenceObject $user.allAccountGroupRoles.name -IncludeEqual) | Where-Object SideIndicator -eq "=="
    }
    if($compare){$isServiceAccount = $true}
    else{$isServiceAccount = $false}
    
}
catch{
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    throw $Err.Exception 
}
return $isServiceAccount
}

function isLocal{
    param(
        $userId
    )
try {
    #Check if member has local auth type
    if($user.email.Contains($localDomain) -eq $true){$isLocal = $true}
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

#region Main process
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
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value ($user.loginAccountGroup.accountGroupName -join ",")
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                    
                    $foundAccounts += $object
                    
                }
        }
    else{
        foreach ($user in $userlist)
        {      
            ### check if is admin or service account
                    $isadmin = isAdmin -userId $user -adminroles $adminroles
                    $isServiceAccount = isServiceAccount -userId $user -svcAccountRoles $svcAccountRoles
                    $isLocal = isLocal -userId $user           
                
            if($isAdmin -eq $true -or $isSvcAcct -eq $true){
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value ($user.loginAccountGroup.accountGroupName -join ",")
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $islocal
                    
                    $foundAccounts += $object
            }        

            }
          
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