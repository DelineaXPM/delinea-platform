#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = "https://" + $args[1]
    [string]$accesstoken = $args[2]
    [boolean]$federationEnabled = [System.Convert]::ToBoolean($args[3])
    [string]$svcTeams = $args[4]    
}
catch {
    $Err = $_   
    throw $args[4]

}




#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\PagerDuty-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "PagerDuty Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceTeamUserList = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$serviceTeamList = New-Object System.Collections.ArrayList
[string] $tokenHeader = "Token token="
[string]$pageSize = 100 #Max Size is 100
#endregion

#region Error Handling Functions
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
#endregion Error Handling Functions


#region Get All Users
 #Create Headers

 function RetrieveUsers {
    param(
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseURL
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        if ("0" -eq ($cursor)) {
            $uri = "$uri/users?limit=$pageSize"
        } else {
            $uri = "$uri/users?offset=$cursor&limit=$pageSize"
        }

        Write-Log -Errorlevel 0 -Message "Requesting Users form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $userObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $userObj
 }

 function RetrieveTeamUsers{
    param(
        [Parameter(Mandatory)]
        [string]$teamId,
        [Parameter(Mandatory)]
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseURL
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        $uri = "$uri/teams/$teamId/members?offset=$cursor&limit=$pageSize"
 

        Write-Log -Errorlevel 0 -Message "Requesting Team Members form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $teamObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $teamObj
 }
 
 function RetrieveTeams {
    param(
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseURL
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        if ("0" -eq ($cursor)) {
            $uri = "$uri/teams?limit=$pageSize"
        } else {
            $uri = "$uri/teams?offset=$cursor&limit=$pageSize"
        }

        Write-Log -Errorlevel 0 -Message "Requesting Users form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $teamsListObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $teamsListObj
    
 }

 function isSvcAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            
    
            foreach ($svcAcctUser in $global:serviceTeamUserList)
            { 
                if($svcAcctUser.id -eq $userId)
                {
                    $isSvcAcct = $true
                    return $isSvcAcct
                } 
                else
                {
                    $isSvcAcct = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isSvcAcct  
}
#endregion

#Main Region
#Check Advanced features: Build ArrayList of Users that belong to the specified teams.
try {
    if ($DiscoveryMode -eq "Advanced") {
    
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        ##Create Roles Array
        
        $more = $true
        $offset = 0
        while ($false -ne $more) {
            $allTeamsObj = RetrieveTeams($offset)

            $teamList = $allTeamsObj.teams
            foreach ($team in $teamList) {
                $teamobject = New-Object -TypeName PSObject
                $teamobject | Add-Member -MemberType NoteProperty -Name name -Value $team.name
                $teamobject | Add-Member -MemberType NoteProperty -Name id -Value $team.id
                [void] $serviceTeamList.add($teamobject)
            }
            $more = $allTeamsObj.more
            $offset = $allTeamsObj.offset + $pageSize
        }
      
        if ($svcTeams)
        {
            ### Create Array of Service Account Groups
            $svcTeamArray = $svcTeams.split(",")
            #Clear Parameter List            
                   
                    foreach($team in $svcTeamArray )
                    {
                        $foundteam = $serviceTeamList | Where-Object {$_.name -eq $team}
                        if ($foundteam -ne $null) {
                            $more = $true
                            $offset = 0
                            while ($false -ne $more) {
                                $roleListObj = RetrieveTeamUsers -cursor $offset -teamId $foundteam.id
                                $roleList = $roleListObj.members
                                foreach ($role in $roleList) {
                                    $svcuser = $role.user
                                    $svcUserobject = New-Object -TypeName PSObject
                                    $svcUserobject | Add-Member -MemberType NoteProperty -Name name -Value $svcuser.summary
                                    $svcUserobject | Add-Member -MemberType NoteProperty -Name id -Value $svcuser.id
                                    [void] $global:serviceTeamUserList.add($svcUserobject)  
                                }
                                $more = $roleListObj.more
                                $offset = $roleListObj.offset + $pageSize       
                            }

                        }
                        
                    }
        }       
    } 
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Analyze Advanced Features"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}


try {

    $tenantUrl = $baseURL

    #region Build User List
    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    $userObj = RetrieveUsers

    #Traverse though the list of Users in the system and determine if they are Privileged Accounts
    $more = $true
    $offset = 0
    while ($false -ne $more) {
        $userObj = RetrieveUsers($offset)

        $usersList = $userObj.users
        foreach ($user in $usersList) {
            if ($false -eq $federationEnabled ) {
                # All accounts get added to ArrayList because they are all local accounts
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
                $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                    #Check for Account Admins
                    if (($user.role -eq "owner") -or ($user.role -eq "admin")) {
                        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true
                    } else {
                        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
                    }
                    #Check is Account is Service Account
                    if (isSvcAccount -userId $user.id) {
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
                    } else {
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false
                    }
                }
                [void] $adminAccounts.add($object)

            } else {
                
                # Since Federation is turned on we are only looking for accounts if Advanced Mode was selected
                $isFound = $false
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
                $object | Add-Member -MemberType NoteProperty -Name username -Value $user.email
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                    #Check for Account Admins
                    if (($user.role -eq "owner") -or ($user.role -eq "admin")) {
                        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true
                        $isFound = $true
                    } else {
                        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
                    }
                    #Check is Account is Service Account
                    if (isSvcAccount -userId $user.id) {
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
                        $isFound = $true
                    } else {
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false
                    }
                    if ($isFound) {
                        [void] $adminAccounts.add($object)
                    }
                }
            }
            
        }
        $more = $userObj.more
        $offset = $userObj.offset + $pageSize

    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Analyze the Users"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

#end region

#endregion Main Process
return $adminAccounts


