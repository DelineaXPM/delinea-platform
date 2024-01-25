# Expected Argd args=@("Discovery Mode Advanced/Default", "FiveTran Tenenant Base URL", "FiveTran API ClientId","FiveTran API ClientSecret","Admin Account Teams IDs","Service Account Teams Ids"  )


## This block will be used when passing args in from Secret Server

    $DiscoveryMode     = $args[0]
    $baseURL           = $args[1]
    $clientID          = $args[2]
    $clientSecret      = $args[3]
    $adminTeamsIds     = $args[4]
    $serviceTeamsIDs   = $args[5]
    $federatedDomains  = $args[6]


    #Create Filter arrays
    $federatedDomainsArray = $federatedDomains.split(",")

#region define variables
#Script Constants
[string]$userApi        = "$baseURL/v1/users" 
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Fivetran.log"
[int32]$LogLevel              = 2
[string]$logApplicationHeader = "FiveTran Discovery"
$globalResults                = @{}
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($clientId):$($clientSecret)"))

#endregion

#region Error Handling
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
#endregion

#region Script Find Admin Functions
function get-AdminAccounts{
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving List: Admin Users"       
        ##Create Roles Array
      
        If ($adminTeamsIDs -ne $null) {
            ### Create Array of Admin Roles
            
            #Clear Parameter List
            $adminTeamUsers = @()

            foreach ($team in $adminTeamsIDs.split(",").split('=')[1] ) {
                $team=$team.trim()

                $uri = 'https://api.fivetran.com/v1/teams/{0}/users' -f $team
                $returnedAdminTeamUsers = Invoke-RestMethod -Uri $uri -Headers @{"Authorization" = "Basic $base64AuthInfo"} -Method Get
                
                foreach ($user in $returnedAdminTeamUsers.data.items.user_id) {
                    $adminTeamUsers += $user  # make sure this is correct form
                }

                Write-Log -ErrorLevel 0 -Message "  Successfully found $($adminTeamUsers.Count) Admin Accounts"    
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve: Admin User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }

    return $adminTeamUsers    
} 


function isAdmin ( [string]$userId ) {
    try {
        foreach ($adminUser in $globalResults.adminUsers)
        { 
            if($adminUser -eq $userId) {
                $isadmin = $true
                break
            } 
            else {
                $isadmin = $false
            }
            
        }
    }

    catch  {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED: Check if Admin Acct"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception <#Do this if a terminating exception happens#>
    }
            
    return $isadmin
}

#endregion Get Admin Users  

#region Script Find Service Accounts Functions
function get-SvcAccounts {
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving List: Service Users"       
        ##Create Roles Array
      
        If ($serviceTeamsIDs -ne $null) {
            ### Create Array of Service Roles
            
            #Clear Parameter List
            $svcTeamUsers = @()

            foreach ($team in $serviceTeamsIDs.split(",").split('=')[1] ) {
                $team=$team.trim()

                $uri = 'https://api.fivetran.com/v1/teams/{0}/users' -f $team
                $returnedSvcTeamUsers = Invoke-RestMethod -Uri $uri -Headers @{"Authorization" = "Basic $base64AuthInfo"} -Method Get
                
                foreach ($user in $returnedSvcTeamUsers.data.items.user_id) {
                    $svcTeamUsers += $user  # make sure this is correct form
                }

                Write-Log -ErrorLevel 0 -Message "  Successfully found $($svcTeamUsers.Count) Service Accounts"    
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve: Service User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }

    return $svcTeamUsers   
}


function isSvc ( [string]$userId ) {
    try {
        foreach ($svcUser in $globalResults.svcUsers)
        { 
            if($svcUser -eq $userId) {
                $isSvc = $true
                
                break
            } 
            else {
                $isSvc = $false
            }
            
        }
    }

    catch  {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED: Check if Service Acct"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception <#Do this if a terminating exception happens#>
    }
            
    return $isSvc
}

#endregion

function isLocal{
    param(
       [string]$userId 
   
    )
    try
    {
       
        foreach ($domain in $federatedDomainsArray)
        {
            $domain = $domain.trim()
            if($domain -eq $userId.Split("@")[1])
            {
                $isLocal = $true
                
                break
            } 
            else
            {
                $isLocal = $false
            }
               
        }
        
    }
    catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED: Check if Local Acct"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception     
    }        
`  return $isLocal
}
#endregion

#region Main Process
####################################
### Main Body Commands
###


#define Output Array
$foundAccounts = @()
   
Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users"  

    # get list of all users ...
    $allUsers = Invoke-RestMethod -Uri $userApi -Headers @{"Authorization" = "Basic $base64AuthInfo"} -Method Get 
    $globalResults.adminUsers = get-AdminAccounts
    $globalResults.svcUsers = get-SvcAccounts
    foreach ($user in $allUsers.data.items)  {
        if ($user.active -eq $false) { continue }
        ### $userDetails = Get-UserDetails $user
        $isAdmin = isadmin $user.Id
        $isSvcAccount = isSvc $user.id
        $isLocal = isLocal -userId $user.email
        $object = New-Object -TypeName PSObject

        ###$Timestamp = get-date -Format $timeformat
        ###$object | Add-Member -MemberType NoteProperty -Name Timestamp -Value $Timestamp
        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL       
        $object | Add-Member -MemberType NoteProperty -Name Username -Value $User.email
        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isAdmin
        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAccount
        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal

        $foundAccounts += $object
    }    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "FAILED:  Account Discovery-Filtering"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
#endregion Main Process
$totalAccount = $foundAccounts.count
Write-Log -ErrorLevel 0 -Message "successfully Discovered $totalAccount Accounts"

return $foundAccounts
#returning to Secret Server