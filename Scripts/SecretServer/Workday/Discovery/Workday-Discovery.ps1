Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"
  <#
  .SYNOPSIS
  Discover Workday Service Accounts and Admins
  
  .DESCRIPTION
  This script will discover Service and Admin Accounts and Local Accounts. It will authenticate leveraging an unencrpyted RSA 256 bit alg key
  Admins are defined by either A: being in the accounts that have the name admin in them or B: defined in the job.  
  Service Accounts are determined by being an Integration Service User.
  Local Accounts are defined as accounts that do not have email 
  .EXAMPLE
  An example
  This is an example of Args to be passed into the Script
  $args = @("TypeOfAccountDiscovery","WorkdayDefinedGroups","clientid", "Username", "RaaSEndpoint", "TokenUri", "privateKeyPEM")
  .NOTES
  General notes
 1. Depricated
  2. WorkdayDefinedGroups: Target Admin account group membership String, but can be null and will pull all groups that have the phrase "admin" in them
  3. ClientID: Client ID of the OAUTH2 service account
  4. Username: The issuer of the token; in a non UPN Format
  5. RaaSEndpoint: Report as a Service REST endpoint. 
  6. TokenUri: The token uri that is for OAUTH2 authentication
  #>

[string[]]$WorkdayDefinedGroups = $args[0]
[string]$clientid = $args[1]
[string]$username =  $args[2]
[string]$RaaSEndpoint =  $args[3]
[string]$TokenUri = $args[4]
$privateKeyPEM = $args[5]
#Logging vars
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Workday-Discovery.log"


#####
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Workday Discovery"
[bool]$LogFileCheck = $true



function Get-WorkdayJWTToken{
    try{
        $jwttoken = $(Get-JWT -aud "wd2" -iss $clientid -sub $username -privkey $privateKeyPEM -exp 5)
        return $(Invoke-RestMethod -Method Post -Uri $TokenUri  -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} -Body "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$($jwttoken)").access_token
      }
      catch {
        $exception = New-Object System.Exception "Caught some general error When doing The JWT auth: `nMessage: $($_.Exception.Message)."
        Write-Log -Errorlevel 2 -Message "Caught some general error When doing the JWT auth: `nMessage: $($_.Exception.Message)." -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $exception
      }
}

$token = Get-WorkdayJWTToken
$headers = @{
    "Authorization" = "Bearer $token"
}

function Get-AllWorkdayUsers {
    try{
        $users = $(Invoke-RestMethod -Method GET -Uri $RaaSEndpoint -Headers $headers -ErrorAction Stop).Report_Entry 
        Write-Log -ErrorLevel 0 -Message "Got this many users from Workday: $($users.User_name.Count)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile -LogFileCheck $LogFileCheck
        return $users
      }
      catch {
        $exception = New-Object System.Exception "Caught some general error When doing user search: `nMessage: $($_.Exception.Message)."
        Write-Log -Errorlevel 2 -Message "Caught some general error When doing user search: `nMessage: $($_.Exception.Message)." -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $exception
      }
}

function Get-WorkdayServiceAccounts{
    param (
        [System.Object]$Users
    )
    $foundAccounts = @()
    foreach($user in $users){
        $AccountList = $(New-Object -TypeName psobject)
        if($user.Integration_User = 1){
            if($null -eq $user.email -or $user.email -eq ""){
                Write-Log -ErrorLevel 1 -Message "Workday User ID: $($user.Employee_ID) does NOT have an email; this would be considered a local account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                continue
            }
            Write-Log -ErrorLevel 0 -Message "Workday User ID: $($user.User_Name) was found as a Service account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            $AccountList | Add-Member -MemberType NoteProperty -Name Domain -Value $($user.email.split("@")[1]) 
            $AccountList | Add-Member -MemberType NoteProperty -Name username -Value $user.User_Name 
            $AccountList | Add-Member -MemberType NoteProperty -Name Email -Value $user.email
            $AccountList | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false 
            $AccountList | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
            $AccountList | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false 
            $foundAccounts += $AccountList
        }   
    }
    Write-Log -ErrorLevel 0 -Message "Found this many service accounts: $($foundAccounts.Count)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    return $foundAccounts
}

function Get-WorkdayAdminAccounts{
    param (
        [System.Object]$Users,
        [string[]]$WorkdayDefinedGroups=$null
    )
    $foundAccounts = @()
    if($null -ne $WorkdayDefinedGroups -or $WorkdayDefinedGroups -eq ""){
        foreach($wdaygroup in $WorkdayDefinedGroups){
            foreach($user in $users){
                foreach($group in $user.Security_Groups_group.Reference_ID){
                    if($wdaygroup -match $group){
                        $AccountList = $(New-Object -TypeName psobject)
                        Write-Log -ErrorLevel 0 -Message "Found an admin group; the group list for the user is $($user.Security_Groups_group.Reference_ID)"-logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                        if($null -eq $user.email -or $user.email -eq ""){
                            Write-Log -ErrorLevel 1 -Message "Workday User ID: $($user.Employee_ID) does NOT have an email; this would be considered a local account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                            continue
                        }
                        Write-Log -ErrorLevel 0 -Message "Workday User ID: $($user.User_Name) was found as an admin account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                        $AccountList | Add-Member -MemberType NoteProperty -Name Domain -Value $($user.email.split("@")[1]) 
                        $AccountList | Add-Member -MemberType NoteProperty -Name username -Value $user.User_Name
                        $AccountList | Add-Member -MemberType NoteProperty -Name Email -Value $user.email
                        $AccountList | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true 
                        $AccountList | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false 
                        $AccountList | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                        $foundAccounts += $AccountList
                    }
                }

            }
        }
    }        
    else{
        Write-Log -ErrorLevel 0 -Message "Default Search is on; looking for all accounts that have the groups that have admin in the name" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        foreach($user in $users){
            $AccountList = $(New-Object -TypeName psobject) 
            if($user.Security_Groups_group.Reference_ID -ilike "*admin*"){
                Write-Log -ErrorLevel 0 -Message "Found an admin group; the group list for the user is $($user.Security_Groups_group.Reference_ID)"-logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                if($null -eq $user.email -or $user.email -eq ""){
                    Write-Log -ErrorLevel 1 -Message "Workday User ID: $($user.Employee_ID) does NOT have an email; this would be considered a local account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                    continue
                }
                Write-Log -ErrorLevel 0 -Message "Workday User ID: $($user.User_Name) was found as an admin account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
                $AccountList | Add-Member -MemberType NoteProperty -Name Domain -Value $($user.email.split("@")[1]) 
                $AccountList | Add-Member -MemberType NoteProperty -Name username -Value $user.User_Name
                $AccountList | Add-Member -MemberType NoteProperty -Name Email -Value  $user.email
                $AccountList | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true 
                $AccountList | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false 
                $AccountList | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                $foundAccounts += $AccountList
            }
        }
    }
    Write-Log -ErrorLevel 0 -Message "Found this many admin accounts: $($foundAccounts.Count)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
    return $foundAccounts
}

function Get-WorkdayLocalAccounts{
    param(
        [System.Object]$Users
    )
    $foundAccounts = @()
    foreach($user in $users){
        $AccountList = $(New-Object -TypeName psobject) 
        if($null -eq $user.email -or $user.email -eq ""){
            Write-Log -ErrorLevel 0 -Message "Workday User ID: $($user.User_Name) was found as a local account. Continuing" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
            $AccountList | Add-Member -MemberType NoteProperty -Name Domain -Value "N/A" 
            $AccountList | Add-Member -MemberType NoteProperty -Name username -Value $user.User_Name
            $AccountList | Add-Member -MemberType NoteProperty -Name Email -Value "N/A"
            $AccountList | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false 
            $AccountList | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false 
            $AccountList | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
            $foundAccounts += $AccountList
        }
    }
    Write-Log -ErrorLevel 0 -Message "Found this many local accounts: $($foundAccounts.Count)" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile    
    return $foundAccounts
}


    
        Write-Log -ErrorLevel 0 -Message "Going to look for service Accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Get-WorkdayServiceAccounts -Users $(Get-AllWorkdayUsers)
   
        Write-Log -ErrorLevel 0 -Message "Going to look for admin accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Get-WorkdayAdminAccounts -Users $(Get-AllWorkdayUsers) -WorkdayDefinedGroups $WorkdayDefinedGroups
   
        Write-Log -ErrorLevel 0 -Message "Going to look for local accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        Get-WorkdayLocalAccounts -Users $(Get-AllWorkdayUsers)
    
  



  