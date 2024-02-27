<#
  .SYNOPSIS
  Discover Workday Service Accounts and Admins
  
  .DESCRIPTION
  This script will discover Service, Admin, and Local Accounts. It will authenticate leveraging an unencrpyted RSA 256 bit alg key.
  Admins are defined by either A: being in the accounts that have the name admin in them or B: defined in the job.  
  Service Accounts are determined by being an Integration Service User.
  Local Accounts are defined as accounts that do not have email 
  .EXAMPLE
  An example
  This is an example of Args to be passed into the Script
  $args = @("TypeOfAccountDiscovery","WorkdayDefinedGroups","clientid", "Username", "RaaSEndpoint", "TokenUri", "privateKeyPEM")
  .NOTES
  General notes
  1. WorkdayDefinedGroups: Target Admin account group membership String, but can be null and will pull all groups that have the phrase "admin" in them
  2. ClientID: Client ID of the OAUTH2 service account
  3. Username: The issuer of the token; in a non UPN Format
  4. RaaSEndpoint: Report as a Service REST endpoint. 
  5. TokenUri: The token uri that is for OAUTH2 authentication
  #>

Import-Module -Name "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\Delinea.PoSH.Helpers\Utils.psm1"  

[string[]]$WorkdayDefinedGroups = $args[0]
[string]$clientid = $args[1]
[string]$username =  $args[2]
[string]$RaaSEndpoint =  $args[3]
[string]$TokenUri = $args[4]
$privateKeyPEM = $args[5]
#Logging vars
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Workday-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Workday Discovery"




function Get-WorkdayJWTToken{
    try{
        $jwttoken = $(Get-JWT -aud "wd2" -iss $clientid -sub $username -privkey $privateKeyPEM -exp 5)
        return $(Invoke-RestMethod -Method Post -Uri $TokenUri  -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} -Body "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$($jwttoken)").access_token
      }
      catch {
        $exception = New-Object System.Exception "General error encountered while doing the JWT auth: `nMessage: $($_.Exception.Message)."
        Write-Log -Errorlevel 2 -Message "General error encountered while doing the JWT auth: `nMessage: $($_.Exception.Message)." -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
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
        return $users
      }
      catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "iGet All Users failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
      }
}

function IsServiceAccount{
    param (
        [System.Object]$User
    )
  
    try {
        

       
        if($user.Integration_User = 1){
            $isServiceAccount = $true
                
            }
        else {
            $isServiceAccount = $false
        }   
          
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "isServiceAccount function Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
        Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
        throw $Err.Exception
    }    
    
    return $isServiceAccount
}

function isAdminAccount{
    param (
        [System.Object]$User
       
    )
    try {
        
   
    $isAdmin = $false
    if($null -ne $WorkdayDefinedGroups -or $WorkdayDefinedGroups -eq ""){
        foreach($wdaygroup in $WorkdayDefinedGroups){
            
                foreach($group in $user.Security_Groups_group.Reference_ID){
                    if($wdaygroup -match $group){

                        $isAdmin = $true
                        Break
                    }
                }

            if($isadmin -eq $true){break}
        }
    }        
    else{
    
            if($user.Security_Groups_group.Reference_ID -ilike "*admin*"){
                
                $isAdmin = $true

                
            }
        
    }
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "isServiceAccount function Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
    Write-Log -ErrorLevel 2 -Message $Err.Exception  -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
    throw $Err.Exception
}
   return $isAdmin
}

function isLocalAccount{
    param(
        [System.Object]$User
    )

  try {
    
 
       
        if($null -eq $user.email -or $user.email -eq ""){
            $isLocal = $true
        }
        else {
            $isLocal = $false
        }
    }
    catch {
      $Err = $_
      Write-Log -ErrorLevel 0 -Message "isLocalAccount function Failed" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
      Write-Log -ErrorLevel 2 -Message $Err.Exception -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
      throw $Err.Exception
    }
  return $isLocal
}

$users = Get-AllWorkdayUsers
$foundAccounts = @()
foreach($user in $users)  
    {
        if($user.Account_Disabled -eq 1 ){continue}
        $isAdmin = isAdminAccount -User $user
        $isServiceAccount = IsServiceAccount -User $user
        $isLocal = isLocalAccount -User $user

        $Account = $(New-Object -TypeName psobject)
        if ($user.email)
        {
            $domain = $user.email.split("@")[1]
            $email =  $user.email
        }
        else {
            $domain = "Local"
            $email =  "not Avalable"
        }
        $Account | Add-Member -MemberType NoteProperty -Name Domain -Value $domain
        $Account | Add-Member -MemberType NoteProperty -Name username -Value $user.User_Name
        $Account | Add-Member -MemberType NoteProperty -Name Email -Value $email
        $Account | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isAdmin
        $Account | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
        $Account | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
        $foundAccounts += $Account
    }

$users_found = $foundAccounts.Count
Write-Log -ErrorLevel 0 -Message "Discovery found $users_found  accounts" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile 
Return $foundAccounts